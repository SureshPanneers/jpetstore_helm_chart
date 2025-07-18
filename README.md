# Cisco Demo Project Documentation for WAR Deployment to EKS Clusters

---

## 🛠️ Prerequisites and Configuration

### Install Required Packages on Jenkins Server

#### ✅ Java Installation
```bash
sudo dnf install java-17-amazon-corretto -y
```

#### ✅ Jenkins Installation
```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
```
#### ✅ Docker Installation
```bash
sudo yum install docker
```

#### ✅ kubectl CLI Installation Installation
```bash
 curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl
 curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl.sha256
 sha256sum -c kubectl.sha256
 chmod +x ./kubectl
 mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
 echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
 source ~/.bashrc
 kubectl version --client
```
#### ✅ eksctl CLI Installation Installation
```bash
    sudo yum install awscli -y
    curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
    chmod +x ./aws-iam-authenticator
    sudo mv ./aws-iam-authenticator /usr/local/bin
    aws-iam-authenticator help
```
#### ✅ aws confirgure
```bash
    aws configure
    aws sts get-caller-identity
```

#### ✅ Access EKS cluster 
```bash
    aws eks update-kubeconfig --region ca-central-1 --name poc-demo-cluster
```

#### ✅ AWS ALB Loadbalancer Controller Setup 
```bash
    cluster_name=poc-demo-cluster
    oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
    echo $oidc_id
    aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4
    eksctl utils associate-iam-oidc-provider --region ca-central-1 --cluster poc-demo-cluster --approve
    eksctl get iamserviceaccount --cluster poc-demo-cluster
    curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json
   
    aws iam create-policy     --policy-name AWSLoadBalancerControllerIAMPolicy     --policy-document file://iam_policy.json
   
   eksctl create iamserviceaccount --cluster=poc-demo-cluster --namespace=kube-system  --region ca-central-1  --name=aws-load-balancer-controller   --role-name AmazonEKSLoadBalancerControllerRole  --attach-policy-arn=arn:aws:iam::189693864407:policy/AWSLoadBalancerControllerIAMPolicy   --approve

   helm repo add eks https://aws.github.io/eks-charts
   helm repo update eks
   helm install aws-load-balancer-controller eks/aws-load-balancer-controller   -n kube-system   --set clusterName=poc-demo-cluster   --set region=ca-central-1   --set serviceAccount.create=false   --set serviceAccount.name=aws-load-balancer-controller
   kubectl get deployment -n kube-system aws-load-balancer-controller
   kubectl describe po -n kube-system aws-load-balancer-controller
```

---



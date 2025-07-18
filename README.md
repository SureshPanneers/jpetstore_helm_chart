Cisco Demo Project Documentation for WAR Deployment to EKS Clusters
 Prerequisites and Configuration
Install Required Packages on Jenkins Server
✅ Java Installation
sudo dnf install java-17-amazon-corretto -y

Jenkins Installation

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins

Docker Installation
sudo yum install docker

 Kubectl CLI Installation
 curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl
 curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl.sha256
 sha256sum -c kubectl.sha256
 chmod +x ./kubectl
 mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
 echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
 source ~/.bashrc
 kubectl version --client

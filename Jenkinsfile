pipeline {
    agent any

    parameters {
        // Build parameters
        choice(choices: ['', 'dev', 'qa', 'prod'], description: 'Enter the ENVIRONMENT', name: 'ENVIRONMENT')
    }

    environment {
        GIT_REPO = 'https://github.com/kavita1205/jpetstore_helm_chart.git'
        BRANCH = 'main'
        CURRENT_DIR = "jpetstore_gitrepo"        
        DOCKER_ECR_REPO_NAME = "jpetstore"
        HELM_ECR_REPO_NAME = 'jpetstore'
        kubeconfigFile = 'jenkins-eks-credentials-cluster'     
        ageKey = 'Agekey'
        AWS_REGION = 'ca-central-1'
        EKS_CLUSTER_NAME = "poc-demo-cluster"
        TIMESTAMP = new Date().format("yyyyMMddHHmmss")
        DOCKER_TAG = "jpetstore-${TIMESTAMP}"
        AWS_ACCOUNT_ID = "189693864407"
        
    }

    options {
        // Build options
        skipDefaultCheckout(true) // prevent double-checkout
        buildDiscarder(logRotator(numToKeepStr: '3'))
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: "${BRANCH}", url: "${GIT_REPO}"
                sh 'ls -al' // Debug: check what files are checked out
                sh 'git status'
            }
        }

        stage('Compile Code') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                        def ecrRepoUri = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.DOCKER_ECR_REPO_NAME}"
                        echo "ECR Repo URI: ${ecrRepoUri}"
                        echo "Building Docker image with tag: ${env.DOCKER_TAG}"
                         sh """
                                mkdir -p docker-context/target
                                ls -l ${env.WORKSPACE}
                                cp ${env.WORKSPACE}/Dockerfile2 docker-context/
                                cp -R target/* docker-context/target/
                                docker build -t ${ecrRepoUri}:${DOCKER_TAG} docker-context -f docker-context/Dockerfile2 --no-cache
                            """
                    }
                }
            }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                        def ecrRepoUri = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.DOCKER_ECR_REPO_NAME}"
                        echo "Pushing Docker image with tag: ${env.DOCKER_TAG}"

                        sh """
                            aws ecr get-login-password --region ${env.AWS_REGION} | docker login --username AWS --password-stdin ${ecrRepoUri}
                            docker tag ${ecrRepoUri}:${env.DOCKER_TAG} ${ecrRepoUri}:${env.DOCKER_TAG}
                            docker push ${ecrRepoUri}:${env.DOCKER_TAG}
                        """
                    }
                }
            }

        stage("Deploy to EKS Cluster") {
            agent {
                // Build stage agent definition
                dockerfile {
                    filename "Dockerfile"
                    dir '.'
                    // label 'DOCKER-LINUX'
                    args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
                    reuseNode true
                }
            }            
            steps {
                // Get the repo version
                script {
                    // Fetch the latest Helm chart version from repository
                    def chartYaml = readYaml file: "${env.WORKSPACE}/chart/Chart.yaml"
                    env.CHART_VERSION = chartYaml.version
                    echo "Helm Chart Version: ${env.CHART_VERSION}"
                }

                withCredentials([file(credentialsId: "${env.ageKey}", variable: 'ageKey'), file(credentialsId: "${env.kubeconfigFile}", variable: 'KUBECONFIG')]) {
                    sh """ 
                    pwd    
                    cp ${ageKey} /tmp/.config/sops/age/keys.txt
                    export KUBECONFIG=$KUBECONFIG
                    kubectl create namespace jpetstore || true 
                    aws ecr get-login-password --region ${env.AWS_REGION} | helm registry login --username AWS --password-stdin ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com
                    cat ${KUBECONFIG}
                    aws sts get-caller-identity
                    aws eks update-kubeconfig --region ${env.AWS_REGION} --name ${env.EKS_CLUSTER_NAME} --kubeconfig $KUBECONFIG
                    helm secrets upgrade --install ${env.HELM_ECR_REPO_NAME} ${env.WORKSPACE}/chart --set ecr.tag=${env.DOCKER_TAG} --set environment=${params.ENVIRONMENT} --version ${env.CHART_VERSION} -f ${env.WORKSPACE}/values.yaml -f ${env.WORKSPACE}/secrets.yaml -n jpetstore --wait --timeout 20m0s
                    """
                }
            }
        }

        stage('Delete the used docker image') {
            steps {
                script {
                    def ecrRepoUri = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.DOCKER_ECR_REPO_NAME}"
                    echo "Deleting Docker image with tag: ${env.DOCKER_TAG} from Jenkins instance"
                    sh "docker rmi ${ecrRepoUri}:${env.DOCKER_TAG}"
                    sh "docker image prune -f"
                }
            }
        }
    }

    post {
        always {
               
                cleanWs ()
            
        }        
    }
}

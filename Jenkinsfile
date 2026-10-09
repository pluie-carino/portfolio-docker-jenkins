 pipeline {
    agent any

    stages {

        stage('Clone Repository') {
            steps {
                git branch: 'main',
                    credentialsId: 'cd3917a2-c582-4a82-9994-61c0a68e68ff',
                    url: 'https://github.com/pluie-carino/portfolio-docker-jenkins.git'
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-terraform'
                ]]) {
                    bat 'terraform init'
                }
            }
        }

     stage('Check Free Tier Instance Types') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-terraform'
        ]]) {
            bat 'aws ec2 describe-instance-types --region ap-south-1 --filters Name=free-tier-eligible,Values=true --query "InstanceTypes[].InstanceType" --output table'
        }
    }
}

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-terraform'
                ]]) {
                    bat 'terraform plan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-terraform'
                ]]) {
                    bat 'terraform apply -auto-approve'
                }
            }
        }

     

stage('Login to GHCR') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'gcrtoken',
            usernameVariable: 'GHCR_USER',
            passwordVariable: 'GHCR_TOKEN'
        )]) {
            powershell '''
                $env:GHCR_TOKEN | docker login ghcr.io --username $env:GHCR_USER --password-stdin
                if ($LASTEXITCODE -ne 0) {
                    exit $LASTEXITCODE
                }
            '''
        }
    }
}



stage('Build Docker Image') {
    steps {
        bat 'docker build -t ghcr.io/pluie-carino/portfolio-docker-jenkins:latest .'
    }
}

stage('Push Docker Image') {
    steps {
        bat 'docker push ghcr.io/pluie-carino/portfolio-docker-jenkins:latest'
    }
}
    }
 }

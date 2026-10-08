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

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t portfolio-website:latest .'
            }
        }

        stage('Stop Old Container') {
            steps {
                bat 'docker rm -f portfolio-container || exit 0'
            }
        }

        stage('Run New Container') {
            steps {
                bat 'docker run -d -p 8081:80 --name portfolio-container portfolio-website:latest'
            }
        }
    }
}

pipeline {
agent any
stages{
stage('Clone Repository'){
steps {
git branch:'main',
url:'https://github.com/pluie-carino/portfolio-docker-jenkins.git'
}
}
stage('Build Docker Image'){
steps{
bat 'docker build -t portfolio-website:latest .'
}
}
stage('Stop Old Container'){
steps{
bat 'docker rm -f portfolio-container || exit 0'
}
}
stage('Run New Container'){
steps{
bat 'docker run -d -p 8081:80 --name portfolio-container portfolio-website:latest'
}
}
}
}

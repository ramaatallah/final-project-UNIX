pipeline {
    agent any

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/ramaatallah/final-project-UNIX.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('backend') {
                    sh 'docker build -t my-backend-app .'
                }
            }
        }

        stage('Stop Old Container') {
            steps {
                sh 'docker stop backend-container || true'
                sh 'docker rm backend-container || true'
            }
        }

        stage('Run New Container') {
            steps {
                sh 'docker run -d -p 3000:3000 --name backend-container my-backend-app'
            }
        }
    }
}
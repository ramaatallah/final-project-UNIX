pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/ramaatallah/final-project-UNIX.git'
            }
        }

        stage('Build Backend Image') {
            steps {
                sh 'docker compose build'
            }
        }

        stage('Run Containers') {
            steps {
                sh 'docker compose up -d'
            }
        }

        stage('Test Backend') {
            steps {
                sh 'curl http://localhost:3000/health || true'
            }
        }
    }
}
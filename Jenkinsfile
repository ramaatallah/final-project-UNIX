pipeline {
    agent any

    stages {

        stage('Pull Code') {
            steps {
                echo 'PULL CODE'
                git branch: 'main',
                    url: 'https://github.com/ramaatallah/final-project-UNIX.git'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploy على Docker...'
                sh 'docker rm -f mysql-db || true'
                sh 'docker compose down || true'
                sh 'docker compose build'
                sh 'docker compose up -d'
            }
        }

        stage('Test') {
            steps {
                echo 'اختبار...'
                sh 'sleep 10 && curl http://localhost:3000/health'
            }
        }

    }

    post {
        success {
            echo 'التطبيق اتحدث!'
        }
        failure {
            echo 'في مشكلة!'
        }
    }
}
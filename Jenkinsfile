pipeline {
    agent any

    stages {

        stage('Pull Code') {
            steps {
                echo '📥 سحب الكود...'
                git branch: 'main',
                    url: 'https://github.com/ramaatallah/final-project-UNIX.git'
            }
        }

        stage('Deploy') {
            steps {
                echo '🐳 Deploy على Docker...'
                sh 'cd /home/ramaatallah/final-project && docker compose down || true'
                sh 'cd /home/ramaatallah/final-project && docker compose build'
                sh 'cd /home/ramaatallah/final-project && docker compose up -d'
            }
        }

        stage('Test') {
            steps {
                echo '🧪 اختبار...'
                sh 'sleep 5 && curl http://localhost:3000/health'
            }
        }

    }

    post {
        success {
            echo '✅ التطبيق اتحدث!'
        }
        failure {
            echo '❌ في مشكلة!'
        }
    }
}
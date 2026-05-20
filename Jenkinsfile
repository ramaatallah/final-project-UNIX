pipeline {
    agent any

    stages {

        stage('Pull Code') {
            steps {
                echo '📥 سحب الكود من GitHub...'
                git branch: 'main',
                    url: 'https://github.com/ramaatallah/final-project-UNIX.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '📦 تثبيت المكتبات...'
                dir('backend') {
                    sh 'npm install'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 بناء Docker Image...'
                sh 'docker compose build'
            }
        }

        stage('Deploy Container') {
            steps {
                echo '🚀 تشغيل الـ Container...'
                sh 'docker compose down || true'
                sh 'docker compose up -d'
            }
        }

        stage('Test') {
            steps {
                echo '🧪 اختبار التطبيق...'
                sh 'sleep 5 && curl http://localhost:3000/health'
            }
        }

    }

    post {
        success {
            echo '✅ التطبيق شغال بنجاح على Docker!'
        }
        failure {
            echo '❌ في مشكلة!'
        }
    }
}
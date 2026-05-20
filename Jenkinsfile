pipeline {
    agent any

    stages {

        stage('Pull Code') {
            steps {
                echo 'pull the code from gitHub...'
                git branch: 'main',
                    url: 'https://github.com/ramaatallah/final-project-UNIX.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'installing dependencies..'
                sh 'cd backend && npm install'
            }
        }

        stage('Run Application') {
            steps {
                echo 'run app ..'
                sh 'pkill -f "node server.js" || true'
                sh 'cd backend && nohup node server.js &'
            }
        }

        stage('Test') {
            steps {
                echo 'test app ..'
                sh 'sleep 3 && curl http://localhost:3000/health'
            }
        }

    }

    
}
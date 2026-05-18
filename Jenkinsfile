// =============================================================================
// Jenkinsfile – Declarative Pipeline for Recommendation System
// =============================================================================
// Stages:
//   1. Checkout  – Pull source code from SCM
//   2. Lint      – Validate docker-compose syntax
//   3. Build     – Build Docker images
//   4. Test      – Spin up stack and run a smoke test
//   5. Deploy    – Start stack in detached mode (production)
//   6. Cleanup   – Always remove test containers (post block)
// =============================================================================

pipeline {

    agent any

    // ── Environment Variables ─────────────────────────────────────────────
    environment {
        // Use Jenkins Credentials Store for secrets (never hardcode passwords)
        MYSQL_ROOT_PASSWORD = credentials('mysql-root-password')
        MYSQL_PASSWORD      = credentials('mysql-app-password')
        MYSQL_USER          = 'appuser'
        MYSQL_DATABASE      = 'recommendation_db'

        // Docker Compose project name (avoids collision with other pipelines)
        COMPOSE_PROJECT_NAME = "rec-system-${env.BUILD_NUMBER}"
    }

    // ── Pipeline Options ──────────────────────────────────────────────────
    options {
        timeout(time: 15, unit: 'MINUTES')    // Kill the build if it hangs
        disableConcurrentBuilds()             // Only one build at a time
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    // ══════════════════════════════════════════════════════════════════════
    stages {

        // ── Stage 1: Checkout ─────────────────────────────────────────────
        stage('Checkout') {
            steps {
                echo '📥 Pulling source code...'
                checkout scm
            }
        }

        // ── Stage 2: Validate Compose File ───────────────────────────────
        stage('Validate Config') {
            steps {
                echo '🔍 Validating docker-compose.yml syntax...'
                sh 'docker compose config --quiet'
            }
        }

        // ── Stage 3: Build Images ─────────────────────────────────────────
        stage('Build') {
            steps {
                echo '🔨 Building Docker images...'
                sh 'docker compose build --no-cache --pull'
            }
        }

        // ── Stage 4: Smoke Test ───────────────────────────────────────────
        // Spin up the stack, wait for it to be healthy, then hit the API.
        stage('Test') {
            steps {
                echo '🧪 Running smoke test...'
                sh '''
                    # Start services in detached mode
                    docker compose up -d

                    # Wait up to 60 s for the backend to be reachable
                    echo "Waiting for backend to be ready..."
                    for i in $(seq 1 12); do
                        if curl -sf http://localhost:3000/recommend?input=hot; then
                            echo "\\n✅ Backend is up!"
                            break
                        fi
                        echo "Attempt $i/12 – not ready yet, retrying in 5s..."
                        sleep 5
                    done

                    # Assert the response contains a recommendation
                    RESPONSE=$(curl -sf http://localhost:3000/recommend?input=hot)
                    echo "Response: $RESPONSE"
                    echo "$RESPONSE" | grep -q "recommendation" || {
                        echo "❌ Smoke test FAILED – unexpected response"
                        exit 1
                    }
                    echo "✅ Smoke test PASSED"
                '''
            }
        }

        // ── Stage 5: Deploy ───────────────────────────────────────────────
        stage('Deploy') {
            steps {
                echo '🚀 Deploying application...'
                sh '''
                    # Bring down any old production stack, then start the new one
                    docker compose -p rec-system-prod down --remove-orphans || true
                    docker compose -p rec-system-prod up -d --remove-orphans
                    echo "✅ Application is live at http://localhost:3000"
                '''
            }
        }

    } // end stages

    // ══════════════════════════════════════════════════════════════════════
    // Post Actions – always run, regardless of success/failure
    // ══════════════════════════════════════════════════════════════════════
    post {
        always {
            echo '🧹 Cleaning up test containers...'
            sh "docker compose -p ${COMPOSE_PROJECT_NAME} down --volumes --remove-orphans || true"
        }
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline FAILED. Check logs above for details.'
            // Dump container logs for debugging
            sh "docker compose logs --tail=50 || true"
        }
    }
}

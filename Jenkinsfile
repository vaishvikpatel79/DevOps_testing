pipeline {
    agent any
    parameters {
        string(name: 'REPO_URL', defaultValue: 'https://github.com/vaishvikpatel79/DevOps_testing', description: 'Repository URL')
        string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build')
    }
    options { timeout(time: 90, unit: 'MINUTES'); skipDefaultCheckout() }
    environment {
        // Build versioning default: v1 (incremented to v2 only when code updates)
        IMAGE_TAG = "v1"
        IMAGE_NAME = "my_microservices_app_fastapi"
    }
    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                git url: "${params.REPO_URL}", branch: "${params.BRANCH}"
                sh 'git submodule update --init --recursive || true'
            }
        }
        stage('Repository Intelligence') {
            steps {
                sh '''
echo "================================================"
echo "   REPOSITORY INTELLIGENCE SNAPSHOT"
echo "================================================"
echo "Repo type        : monolith"
echo "Language         : python"
echo "Framework        : fastapi"
echo "Build strategy   : dockerfile"
echo "Buildable svcs   : 1"
echo "Dockerfile reused: True"
echo "Compose reused   : False"
echo "Jenkinsfile reuse: False"
echo "================================================"
'''
            }
        }
        stage('Validate Build Strategy') {
            steps {
                sh '''
set -eu
test -f "Dockerfile" || (echo "ERROR: Dockerfile not found in workspace after checkout" && exit 1)
echo "[validate] Build strategy validated: dockerfile"
'''
            }
        }
        stage('Build Service Image') {
            steps {
                sh '''
docker build -f "Dockerfile" -t "${IMAGE_NAME}:${IMAGE_TAG}" "."
docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}" >/dev/null
'''
            }
        }
        stage('Archive Image') {
            steps {
                sh 'mkdir -p artifact-layers && docker save "${IMAGE_NAME}:${IMAGE_TAG}" | gzip > "artifact-layers/${IMAGE_NAME}-image.tar.gz"'
                archiveArtifacts artifacts: 'artifact-layers/*.tar.gz', fingerprint: true
            }
        }
        stage('Build Metadata') {
            steps {
                script {
                    def meta = [
                        build_strategy: 'dockerfile',
                        repo_type: 'monolith',
                        language: 'python',
                        framework: 'fastapi',
                        build_status: 'success',
                        image: "${IMAGE_NAME}:${IMAGE_TAG}"
                    ]
                    def metaJson = "{\"build_strategy\": \"dockerfile\", \"repo_type\": \"monolith\", \"language\": \"python\", \"framework\": \"fastapi\", \"build_status\": \"success\", \"image\": \"${IMAGE_NAME}:${IMAGE_TAG}\"}"
                    writeFile file: 'build_metadata.json', text: metaJson
                    archiveArtifacts artifacts: 'build_metadata.json', fingerprint: false, allowEmptyArchive: true
                    echo "Build metadata written"
                }
            }
        }

    }
    post {
        always {
            script {
                try {
                    cleanWs()
                } catch (err) {
                    echo "Cleanup: " + err.message
                }
            }
        }
        failure {
            echo 'BUILD FAILED - check console output above'
        }
    }
}

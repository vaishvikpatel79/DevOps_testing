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
        IMAGE_NAME = "my_microservices_app_backend"
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

        stage('Verify Local Images') {
            steps {
                script {
                    def targetImages = [
                    [name: 'my_microservices_app_backend', tag: 'v1']
                ]
                    for (img in targetImages) {
                        def tagToUse = (env.IMAGE_TAG && env.IMAGE_TAG != '') ? env.IMAGE_TAG : img.tag
                        def localImg = "${img.name}:${tagToUse}"
                        echo "Verifying local docker image exists: ${localImg}"
                        if (sh(script: "docker image inspect ${localImg} >/dev/null 2>&1", returnStatus: true) != 0) {
                            if (sh(script: "docker image inspect ${img.name}:${img.tag} >/dev/null 2>&1", returnStatus: true) == 0) {
                                localImg = "${img.name}:${img.tag}"
                            } else if (env.IMAGE_NAME && sh(script: "docker image inspect ${env.IMAGE_NAME}:${tagToUse} >/dev/null 2>&1", returnStatus: true) == 0) {
                                localImg = "${env.IMAGE_NAME}:${tagToUse}"
                                img.name = env.IMAGE_NAME
                            }
                        }
                        sh "docker image inspect ${localImg} >/dev/null"
                    }
                }
            }
        }

        stage('Verify Google Cloud Access') {
            steps {
                script {
                    def hasGcloud = sh(script: "command -v gcloud >/dev/null 2>&1", returnStatus: true) == 0
                    if (hasGcloud) {
                        def authRc = sh(
                            script: "gcloud auth list 2>/dev/null || true",
                            returnStdout: true
                        ).trim()
                        if (!authRc) {
                            echo "Notice: gcloud auth check returned empty — ensuring authentication active."
                        }
                        def gcpProject = 'cloudteam-490409'.trim() ?: (env.GCP_PROJECT_ID ?: '')
                        if (gcpProject) {
                            sh "gcloud config set project ${gcpProject} > /dev/null 2>&1 || true"
                            env.GCP_PROJECT_ID = gcpProject
                            echo "Google Cloud project configured: ${gcpProject}"
                        }
                    } else {
                        echo "Notice: 'gcloud' CLI is not installed on Jenkins agent node."
                    }
                }
            }
        }

        stage('Resolve Cloud Account & Registry') {
            steps {
                script {
                    env.GCP_REGION = 'us-central1'
                    env.GAR_REPOSITORY = 'fastapi-demo-dev'
                    def userRegistry = 'us-central1-docker.pkg.dev/cloudteam-490409/fastapi-demo-dev'.trim()
                    if (userRegistry && !userRegistry.contains('localhost')) {
                        env.TARGET_REGISTRY = userRegistry
                        echo "Using User Provided GCP Artifact Registry: ${env.TARGET_REGISTRY}"
                    } else {
                        def gcpProj = env.GCP_PROJECT_ID ?: 'cloudteam-490409'
                        if (!gcpProj) {
                            try {
                                gcpProj = sh(script: 'gcloud config get-value project 2>/dev/null', returnStdout: true).trim()
                            } catch (Exception e) {
                                echo "Warning: Could not fetch GCP project via gcloud: ${e}"
                            }
                        }
                        if (!gcpProj) {
                            gcpProj = 'cloudteam-490409'
                        }
                        env.GCP_PROJECT_ID = gcpProj
                        env.TARGET_REGISTRY = "${env.GCP_REGION}-docker.pkg.dev/${env.GCP_PROJECT_ID}/${env.GAR_REPOSITORY}"
                        echo "Resolved Artifact Registry URI: ${env.TARGET_REGISTRY}"
                    }
                }
            }
        }

        stage('Ensure Repositories Exist') {
            steps {
                script {
                    def hasGcloud = sh(script: "command -v gcloud >/dev/null 2>&1", returnStatus: true) == 0
                    if (!hasGcloud) {
                        echo "Notice: 'gcloud' CLI is not installed on agent node — skipping remote repository auto-creation check."
                    } else {
                        def describeRc = sh(
                            script: "gcloud artifacts repositories describe ${env.GAR_REPOSITORY} --location=${env.GCP_REGION} > /dev/null 2>&1",
                            returnStatus: true
                        )
                        if (describeRc != 0) {
                            echo "Artifact Registry repository not found. Creating..."
                            def createRc = sh(
                                script: "gcloud artifacts repositories create ${env.GAR_REPOSITORY} --repository-format=docker --location=${env.GCP_REGION} --description='Docker repository for container images'",
                                returnStatus: true
                            )
                            if (createRc != 0) {
                                echo "Notice: Could not auto-create Artifact Registry repository via gcloud CLI. Proceeding with push."
                            } else {
                                echo "Artifact Registry repository created."
                            }
                        } else {
                            echo "Artifact Registry repository already exists."
                        }
                    }
                }
            }
        }

        stage('Login To Registry') {
            steps {
                script {
                    def hasGcloud = sh(script: "command -v gcloud >/dev/null 2>&1", returnStatus: true) == 0
                    if (hasGcloud) {
                        def rc = sh(
                            script: "gcloud auth configure-docker ${env.GCP_REGION}-docker.pkg.dev --quiet",
                            returnStatus: true
                        )
                        if (rc != 0) {
                            echo "Warning: gcloud auth configure-docker failed — proceeding with push attempt."
                        } else {
                            echo "Docker authentication configured for GCP Artifact Registry."
                        }
                    } else {
                        echo "Notice: 'gcloud' CLI is not installed on agent node — using local Docker credential store for ${env.TARGET_REGISTRY}."
                    }
                }
            }
        }

        stage('Tag And Push Images') {
            steps {
                script {
                    def targetImages = [
                    [name: 'my_microservices_app_backend', tag: 'v1']
                ]
                    def pushResults = []
                    for (img in targetImages) {
                        def tagToUse = (env.IMAGE_TAG && env.IMAGE_TAG != '') ? env.IMAGE_TAG : img.tag
                        def localImg = "${img.name}:${tagToUse}"
                        if (sh(script: "docker image inspect ${localImg} >/dev/null 2>&1", returnStatus: true) != 0) {
                            if (sh(script: "docker image inspect ${img.name}:${img.tag} >/dev/null 2>&1", returnStatus: true) == 0) {
                                localImg = "${img.name}:${img.tag}"
                            } else if (env.IMAGE_NAME && sh(script: "docker image inspect ${env.IMAGE_NAME}:${tagToUse} >/dev/null 2>&1", returnStatus: true) == 0) {
                                localImg = "${env.IMAGE_NAME}:${tagToUse}"
                                img.name = env.IMAGE_NAME
                            }
                        }
                        def remoteUri = "${env.TARGET_REGISTRY}/${img.name}:${tagToUse}"
                        
                        echo "Tagging ${localImg} -> ${remoteUri}"
                        sh "docker tag ${localImg} ${remoteUri}"
                        
                        echo "Pushing ${remoteUri}..."
                        sh "docker push ${remoteUri}"
                        
                        pushResults.add('{"image_name": "' + img.name + ':' + tagToUse + '", "image_tag": "' + tagToUse + '", "image_uri": "' + img.name + ':' + tagToUse + '", "push_status": "success"}')
                    }
                    env.PUSH_RESULTS_JSON = "[" + pushResults.join(",") + "]"
                }
            }
        }

        stage('Write Push Metadata') {
            steps {
                script {
                    if (env.PUSH_RESULTS_JSON && env.PUSH_RESULTS_JSON != '[]') {
                        sh '''
                            python3 -c 'import json, os; open("push_metadata.json", "w").write(json.dumps(json.loads(os.environ["PUSH_RESULTS_JSON"]), indent=2))'
                        '''
                        archiveArtifacts artifacts: 'push_metadata.json', allowEmptyArchive: true
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    def targetImages = [
                    [name: 'my_microservices_app_backend', tag: 'v1']
                ]
                    for (img in targetImages) {
                        def remoteUri = "${env.TARGET_REGISTRY}/${img.name}:${img.tag}"
                        echo "Removing tagged image: ${remoteUri}"
                        sh "docker rmi ${remoteUri} || true"
                    }
                    sh "docker logout ${env.TARGET_REGISTRY} || true"
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

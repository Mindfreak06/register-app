pipeline {
  agent { label 'Jenkins-Master' }
  tools {
    jdk 'JAVA21'
    maven 'Maven3'
  }
  parameters {
    string(name: 'APP_NAME', defaultValue: 'register-app', description: 'Application name for Docker image')
    string(name: 'RELEASE_TAG', defaultValue: "${env.BUILD_NUMBER ?: 'latest'}", description: 'Release tag for the Docker image (e.g. v1.0.0 or build number)')
    string(name: 'DOCKER_REGISTRY', defaultValue: '', description: 'Optional registry (e.g. docker.io/youruser or ghcr.io/yourorg). Leave empty to skip push')
    string(name: 'DOCKER_IMAGE_NAME', defaultValue: '', description: 'Optional image name (overrides APP_NAME). If empty, APP_NAME is used')
    string(name: 'DOCKER_CREDENTIAL_ID', defaultValue: 'docker-hub', description: 'Jenkins credential id (username/password) to login to the registry')
  }
  environment {
    // You can set DOCKER_REGISTRY and DOCKER_CREDENTIAL_ID in job config or leave as parameters
    IMAGE_NAME = "${params.DOCKER_IMAGE_NAME ?: params.APP_NAME}"
    IMAGE_TAG  = "${params.RELEASE_TAG ?: env.BUILD_NUMBER ?: 'latest'}"
  }

  stages {
    stage('Cleanup Workspace') {
      steps {
        cleanWs()
      }
    }

    stage('Checkout from SCM') {
      steps {
        git branch: 'main', credentialsId: 'github', url: 'https://github.com/Mindfreak06/register-app'
      }
    }

    stage('Build Application') {
      steps {
        sh "mvn clean package"
      }
    }

    stage('Test Application') {
      steps {
        sh 'mvn test'
      }
    }

    stage('Docker: Build & Optional Push') {
      steps {
        script {
          // Build image locally
          def tag = "${IMAGE_NAME}:${IMAGE_TAG}"
          sh "echo Building Docker image ${tag}"
          sh "docker --version || true"
          sh "docker build -t ${tag} ."

          // If DOCKER_REGISTRY provided, tag and push
          if (params.DOCKER_REGISTRY?.trim()) {
            def registry = params.DOCKER_REGISTRY.trim()
            def fullName = "${registry}/${tag}"
            sh "docker tag ${tag} ${fullName}"

            // Use Jenkins credentials (username/password) to login and push
            withCredentials([usernamePassword(credentialsId: params.DOCKER_CREDENTIAL_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
              sh "echo Logging in to ${registry} as ${DOCKER_USER}"
              sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin ${registry}"
              sh "docker push ${fullName}"
            }

            echo "Pushed image: ${fullName}"
          } else {
            echo "DOCKER_REGISTRY not set — built image is available locally as ${tag}. To push, set DOCKER_REGISTRY and a Jenkins credential id in DOCKER_CREDENTIAL_ID."
          }
        }
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonarqube-server') {
          sh 'mvn clean verify sonar:sonar'
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 10, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }
  }
}

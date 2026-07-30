pipeline {
  agent { label 'Jenkins-Master' }
  tools {
    jdk 'JAVA21'
    maven 'Maven3'
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
          // Build a Docker image tagged with the build number. Adjust registry/name as needed.
          def imageName = "register-app:${env.BUILD_NUMBER ?: 'local'}"
          sh "docker build -t ${imageName} ."

          // If you want to push the image, set DOCKER_REGISTRY (e.g. registry.hub.docker.com/username)
          // and configure a credential with id 'docker-hub' (username/password) in Jenkins.
          if (env.DOCKER_REGISTRY) {
            def fullName = "${env.DOCKER_REGISTRY}/${imageName}"
            sh "docker tag ${imageName} ${fullName}"
            withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
              sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin ${env.DOCKER_REGISTRY}"
              sh "docker push ${fullName}"
            }
          } else {
            echo "DOCKER_REGISTRY not set — skipping push. To enable push, set DOCKER_REGISTRY and a 'docker-hub' credential in Jenkins."
          }
        }
      }
    }
    stage('SonarQube Analysis') {
      steps {
        // Uses the SonarQube configuration named 'sonarqube-server' in Jenkins
        withSonarQubeEnv('sonarqube-server') {
          sh 'mvn clean verify sonar:sonar'
        }
      }
    }
    stage('Quality Gate') {
      steps {
        // Wait for SonarQube to process the analysis
          script {
          // This will poll SonarQube and wait for quality gate status
              waitForQualityGate abortPipeline: false, credentialsId:'jenkins-sonarqube-token'
        }
      }
    }
  
  }
}

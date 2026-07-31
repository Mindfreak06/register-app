pipeline {
  agent { label 'Jenkins-Master' }
  tools {
    jdk 'JAVA21'
    maven 'Maven3'
  }
  environment{
    APP_NAME = "register-app-pipeline"
    RELEASE = "1.0.0"
    DOCKER_USER = "mindfreakyinka"
    DOCKER_PASS = 'dockerhub'
    IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}"
  }
  stages {
    stage('Cleanup Workspace') {
      steps { cleanWs() }
    }

    stage('Checkout from SCM') {
      steps {
        git branch: 'main', credentialsId: 'github', url: 'https://github.com/Mindfreak06/register-app'
      }
    }

    stage('Build Application') {
      steps { sh "mvn clean package" }
    }

    stage('Test Application') {
      steps { sh 'mvn test' }
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
       script {
          waitForQualityGate abortPipeline: false,credentialsId: 'jenkins-sonarqube-token'
        }
      }
    }
    stage("Build & Push Docker Images){
          steps{
            script{
              docker.withRegisry('',DOCKER_PASS){
                docker_image = docker.build "${IMAGE_NAME}"
              }
              docker.withRegistry('',DOCKER_PASS){
                docker_image.push("${IMAGE_TAG}")
                docker_image.push('latest')
              }
    }
  }
}

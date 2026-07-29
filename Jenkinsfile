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
        // Waits for SonarQube Quality Gate result; aborts pipeline on failure
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }
  }
}

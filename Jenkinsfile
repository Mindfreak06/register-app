pipeline{
  agent{label 'Jenkins-Master'}
  tools{
    jdk 'JAVA21'
    maven 'Maven3'
  }
  stages{
    stage("Cleanup Workspace") {
      steps{
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
  }
}

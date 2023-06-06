@Library ('folio_jenkins_shared_libs') _

pipeline {

  options {
    timeout(30)
    buildDiscarder(logRotator(numToKeepStr: '3', artifactNumToKeepStr: '3'))
  }

  agent {
    node {
      label 'jenkins-agent-java17'
    }
  }

  stages {
    stage('Setup') {
      steps {
        script {
          currentBuild.displayName = "#${env.BUILD_NUMBER}-${env.JOB_BASE_NAME}"
        }
      }
    }
    stage('Maven Build') {
      steps {
        echo "Building Maven artifacts"
        withMaven(
          jdk: 'openjdk-17-jenkins-slave-all',
          maven: 'maven3-jenkins-slave-all',
          mavenSettingsConfig: 'folioci-maven-settings') {
            sh 'mvn -DskipTests clean install'
        }
      }
    }
  }
}


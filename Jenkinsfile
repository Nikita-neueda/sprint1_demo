pipeline {
    agent any
     tools {
        // This injects the Java 21 paths you configured in Step 1
        jdk 'JDK21'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Image') {
            steps {
                sh 'mvn -B -f ./starter/pom.xml clean package -DskipTests'
                sh 'docker build -t team-skeleton:latest .'
            }
        }
        stage('Smoke Test') {
            steps {
                sh 'docker run --rm team-skeleton:latest'
            }
        }
    }
}

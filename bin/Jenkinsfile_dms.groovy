pipeline {
    agent any
    stages {
        stage('AWS cli in docker') {
            steps {
                sh '''
aws --version
                '''
            }
        }
    }
}
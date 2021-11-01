pipeline {
    agent any
    stages {

        stage('Deploy_gfnsubs') {
            steps {
                sh 'whoami'
            }
        }

        stage('MySQL in docker') {
            agent {
                docker {
                    image 'mysql/mysql-server:5.7'
                    args '--entrypoint='
                }
            }
            steps {
                sh 'mysql --version'
                sh 'ls -al'
            }
        }

        stage('AWS cli in docker') {
            agent {
                docker {
                    image 'amazon/aws-cli:2.3.1'
                    args '--entrypoint='
                }
            }
            steps {
                sh 'aws --version'
                sh 'ls -al'
            }
        }
    }
}
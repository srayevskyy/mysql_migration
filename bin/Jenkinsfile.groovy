pipeline {
    agent any
    environment {
        MYSQL_ROOT_PASSWORD = credentials('MYSQL_ROOT_PASSWORD')
    }
    stages {

        stage('test') {
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
                sh "./bin/release.sh ${MYSQL_DST_HOST} 3306 root ${MYSQL_ROOT_PASSWORD} dms_sample"
            }
        }

        /*
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
        */
    }
}
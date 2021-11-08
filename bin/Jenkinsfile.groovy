pipeline {
    agent any
    environment {
        MYSQL_ROOT_PASSWORD = credentials('MYSQL_ROOT_PASSWORD')
    }
    stages {
        stage('MySQL in docker') {
            steps {
                sh 'mysql --version'
                sh "./bin/release.sh ${MYSQL_DST_HOST} 3306 root ${MYSQL_ROOT_PASSWORD} dms_sample"
            }
        }
    }
}
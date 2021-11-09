def getEnvFromBranch(username) {
    /*
  if (branch == 'master') {
    return 'production'
  } else {
    return 'staging'
  }
    */
    return sh (
        script: "aws rds generate-db-auth-token --hostname $MYSQL_DST_HOST --port 3306 --region us-west-2 --username iam_admin",
        returnStdout: true
    ).trim()
}

pipeline {
    agent any
    environment {
        MYSQL_ROOT_PASSWORD = credentials('MYSQL_ROOT_PASSWORD')
        MYSQL_TOKEN = getMySQLToken("iam_admin")
    }
    stages {
        stage('MySQL in docker') {
            steps {
                sh "mysql --host=${MYSQL_DST_HOST} --port=3306 --ssl-ca=${USER}/rds-ca-2019-root.pem --user=iam_admin --password=${TOKEN} -e 'SELECT 1+1'"
                // sh "./bin/release.sh ${MYSQL_DST_HOST} 3306 root ${MYSQL_ROOT_PASSWORD} dms_sample"
            }
        }
    }
}
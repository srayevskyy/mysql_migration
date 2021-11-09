// def getMySQLToken(username) {
//     return sh (
//         script: "aws rds generate-db-auth-token --hostname $MYSQL_DST_HOST --port 3306 --region us-west-2 --username iam_admin",
//         returnStdout: true
//     ).trim()
// }

pipeline {
    agent any
    // environment {
    //     MYSQL_TOKEN = getMySQLToken("iam_admin")
    // }
    stages {
        stage('Deploy target DB structure and/or truncate tables') {
            steps {
                sh '''
                wget --no-clobber --directory-prefix=${USER} https://s3.amazonaws.com/rds-downloads/rds-ca-2019-root.pem
                MYSQL_TOKEN="$(aws rds generate-db-auth-token --hostname $MYSQL_DST_HOST --port 3306 --region us-west-2 --username iam_admin)"
                echo $MYSQL_TOKEN
                mysql --host=$MYSQL_DST_HOST --port=3306 --ssl-ca=${USER}/rds-ca-2019-root.pem --user=iam_admin --password=$MYSQL_TOKEN
                '''
                // sh "echo ${MYSQL_TOKEN}"
                // sh "mysql --host=${MYSQL_DST_HOST} --port=3306 --ssl-ca=${USER}/rds-ca-2019-root.pem --user=iam_admin --password=${MYSQL_TOKEN} -e 'SELECT 1+1'"
                // sh "./bin/release.sh ${MYSQL_DST_HOST} 3306 root ${MYSQL_ROOT_PASSWORD} dms_sample"
            }
        }
    }
}
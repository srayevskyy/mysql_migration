
pipeline {
    agent any
    stages {
        stage('Deploy target DB structure and/or truncate tables') {
            steps {
                sh '''
                set -x
                wget --no-clobber --directory-prefix=${USER} https://s3.amazonaws.com/rds-downloads/rds-ca-2019-root.pem
                MYSQL_TOKEN="$(aws rds generate-db-auth-token --hostname $MYSQL_DST_HOST --port 3306 --region us-west-2 --username iam_admin)"                
                mysql --host=$MYSQL_DST_HOST --port=3306 --ssl-ca=${USER}/rds-ca-2019-root.pem --user=iam_admin --password=$MYSQL_TOKEN -e "SELECT 1+1"
                '''
                // mysql --host=$MYSQL_DST_HOST --port=3306 --ssl-ca=${USER}/rds-ca-2019-root.pem --user=iam_admin --password=$MYSQL_TOKEN -e "SELECT 1+1"
            }
        }
    }
}
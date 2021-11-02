pipeline {
    agent any
    stages {
        stage('AWS cli in docker') {
            steps {
                sh '''
aws dms create-replication-task \
--replication-task-identifier "mysql-src-to-dst-cli" \
--source-endpoint-arn "arn:aws:dms:us-west-2:627223132631:endpoint:NMWATSHBNY7SGWSU5PQ26O6RPYW7DCU7ND6PPRQ" \
--target-endpoint-arn "arn:aws:dms:us-west-2:627223132631:endpoint:3TYRTDFS7CFBYF7ZK2QSD3EDKZ7POOL3RBMEX5Q" \
--replication-instance-arn "arn:aws:dms:us-west-2:627223132631:rep:NABEOHCFPWNOG5N2J54TLPQR562BHVZGZF34OOI" \
--migration-type "full-load-and-cdc" \
--table-mappings https://raw.githubusercontent.com/srayevskyy/mysql_migration/main/infra/terraform/rds/table_mappings.json
                '''
            }
        }
    }
}
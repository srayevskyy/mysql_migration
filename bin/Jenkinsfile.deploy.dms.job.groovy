pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = credentials('AWS_DEFAULT_REGION')
    }
    stages {
        stage('AWS cli in docker') {
            steps {
                sh '''
aws dms create-replication-task \
--replication-task-identifier "mysql-src-to-dst-cli" \
--source-endpoint-arn "${SOURCE_ENDPOINT_ARN}" \
--target-endpoint-arn "${TARGET_ENDPOINT_ARN}" \
--replication-instance-arn "${REPLICATION_INSTANCE_ARN}" \
--migration-type "full-load-and-cdc" \
--table-mappings https://raw.githubusercontent.com/srayevskyy/mysql_migration/main/infra/terraform/rds/table_mappings.json
                '''
            }
        }
    }
}
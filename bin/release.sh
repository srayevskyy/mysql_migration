#!/bin/bash

set -x
set -e

cd "${0%/*}"

MYSQL_HOST=${1}
MYSQL_PORT=${2}
MYSQL_USER=${3}
SRC_SCHEMA=${4}

function deploy_scripts() {

DIRECTORY=${1}

for i in $(ls -1 ../schemas/${SRC_SCHEMA}/${DIRECTORY}/*.sql)
do
   echo "Executing '${i}' ..."
   mysql -vvv --host=${MYSQL_HOST} --port=${MYSQL_PORT} --ssl-ca=${HOME}/rds-ca-2019-root.pem --user=${MYSQL_USER} --password="${MYSQL_TOKEN}" -e ${i}
done

}

deploy_scripts "release_scripts"

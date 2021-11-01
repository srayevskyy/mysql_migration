#!/bin/bash

set -x
set -e

cd "${0%/*}"

MYSQL_HOST=${1}
MYSQL_PORT=${2}
MYSQL_USER=${3}
MYSQL_PASSWORD=${4}
SRC_SCHEMA=${5}

function deploy_scripts() {

DIRECTORY=${1}

for i in $(ls -1 ../schemas/${SRC_SCHEMA}/${DIRECTORY}/*.sql)
do
   echo "Executing '${i}' ..."
   /usr/bin/mysql -vvv -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} -p{MYSQL_PASSWORD} < ${i}
done

}

deploy_scripts "release_scripts"

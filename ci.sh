#!/bin/bash

set -e

BUILDER_IMAGE="gobuilder"
TEST_CONTAINER="gotest1"
MONGODB_CONTAINER="phenix-mongodb"

if docker ps --all|grep $TEST_CONTAINER; then
  docker rm -f $TEST_CONTAINER
fi

IP=$(/sbin/ifconfig|grep -A 4 -P '^eth'| grep 'inet '|awk -F: '{print $2}'|awk '{print $1}'|head -n 1)

OUTPUT=$(docker run -it --rm --name=$TEST_CONTAINER -e KEY_SERVER_URL=http://$IP:9998 -e JOB_WORKER_URL=http://$IP:5919 -e DB_NAME=phenix_test --link=${MONGODB_CONTAINER}:mongodb -v $WORKSPACE/case.json:/go/src/github.com/mountkin/phenix-api/api/test/case.json $BUILDER_IMAGE /go/src/github.com/mountkin/phenix-api/api/test/run.sh)

cat $OUTPUT

cat $OUTPUT | grep -q PASS

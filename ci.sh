#!/bin/bash

set -e

BUILDER_IMAGE="gobuilder"
TEST_CONTAINER="gotest1"
MONGODB_CONTAINER="phenix-mongodb"

if docker ps --all|grep $TEST_CONTAINER; then
  docker rm -f $TEST_CONTAINER
fi

docker run -it -d --name=$TEST_CONTAINER -e KEY_SERVER_URL=http://127.0.0.1:9998 -e JOB_WORKER_URL=http://127.0.0.1:5919 -e DB_NAME=phenix_test --link=${MONGODB_CONTAINER}:mongodb -v $WORKSPACE/case.json:/go/src/github.com/mountkin/phenix-api/api/test/case.json $BUILDER_IMAGE /go/src/github.com/mountkin/phenix-api/api/test/run.sh

docker wait $TEST_CONTAINER
echo "======================================================"
echo "                 FINAL TEST OUTPUT"
echo "======================================================"
docker logs $TEST_CONTAINER | tee /tmp/ci1118.log
echo "======================================================"

cat /tmp/ci1118.log | grep -q PASS

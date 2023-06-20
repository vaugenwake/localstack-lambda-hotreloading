#!/bin/bash

LOCALSTACK_ENDPOINT="http://localstack:4566"

echo "Invoking lambda"
docker-compose run --rm awslocal /bin/sh -c "awslocal --endpoint-url=$LOCALSTACK_ENDPOINT lambda invoke \
    --function-name hello-world ./invokations/output.txt"

#!/bin/sh

CMD="$@"

AWS_CMD="docker-compose run --rm awslocal awslocal --endpoint-url=http://localstack:4566 ${CMD}"

exec ${AWS_CMD}
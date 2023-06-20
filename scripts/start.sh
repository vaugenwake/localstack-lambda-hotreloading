#!/bin/bash

LOCALSTACK_EXTERNAL_ENDPOINT="http://localhost:4566"
LOCALSTACK_ENDPOINT="http://localstack:4566"
MAX_FAILURES=5
failure_count=0

function_does_not_exist() {
  local function_name="$1"

  echo "Checking if $function_name exists"
  
  docker-compose run --rm awslocal lambda get-function --function-name "$function_name" >/dev/null 2>&1
  
  if [ $? -eq 0 ]; then
    # Function exists
    return 0
  else
    # Function does not exist
    return 1
  fi
}

startup_fail() {
    echo "Localstack failed ${MAX_FAILURES} times. Exiting..."
    docker-compose down
    exit 1
}

localstack_health_check() {
    if curl -s --head --fail "$LOCALSTACK_EXTERNAL_ENDPOINT/health?reload" >/dev/null; then
        echo "Localstack is healthy"
        # Reset failure count on successful response
        failure_count=0
        break
    else
        echo "Waiting for localstack to become healthy"
        ((failure_count++))
        if [[ ${failure_count} -ge ${MAX_FAILURES} ]]; then
            startup_fail
        fi
    fi
}

echo -e "Starting localstack\n"
docker-compose up -d
while true; do
    localstack_health_check
    sleep 3
done

echo -e "Building functions\n"
docker-compose run --rm node npm run build

echo -e "Setting up lambda functions\n"

lambda_function_name="hello-world"

if function_does_not_exist "$lambda_function_name"; then
  echo -e "\nLambda function '$lambda_function_name' does not exist. Creating it...\n"
  docker-compose run --rm awslocal /bin/sh -c "awslocal --endpoint-url=$LOCALSTACK_ENDPOINT lambda create-function \
    --function-name hello-world \
    --runtime "nodejs18.x" \
    --role arn:aws:iam::123456789012:role/lambda-localstack \
    --code S3Bucket="hot-reload",S3Key="$(PWD)/dist" \
    --handler index.handler"
else
  echo -e "\nLambda function '$lambda_function_name' already exists.\n"
fi

echo -e "\nStarting watcher"
docker-compose run --rm node npm run watch

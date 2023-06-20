#!/bin/bash

LOCALSTACK_ENDPOINT="http://localstack:4566"

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

echo "Building"
docker-compose run --rm node npm run build

echo "Setting up lambda\n"

lambda_function_name="hello-world"

if function_does_not_exist "$lambda_function_name"; then
  echo "Lambda function '$lambda_function_name' does not exist. Creating it..."
  docker-compose run --rm awslocal /bin/sh -c "awslocal --endpoint-url=$LOCALSTACK_ENDPOINT lambda create-function \
    --function-name hello-world \
    --runtime "nodejs18.x" \
    --role arn:aws:iam::123456789012:role/lambda-localstack \
    --code S3Bucket="hot-reload",S3Key="$(PWD)/dist" \
    --handler index.handler"
else
  echo "Lambda function '$lambda_function_name' already exists."
fi

echo "Watching..."
docker-compose run --rm node npm run watch

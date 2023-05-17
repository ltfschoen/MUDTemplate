#!/bin/bash

trap "echo; exit" INT
trap "echo; exit" HUP

# assign fallback values for environment variables from .env.example incase
# not declared in .env file. alternative approach is `echo ${X:=$X_FALLBACK}`
source $(dirname "$0")/.env.example
source $(dirname "$0")/.env

printf "\n*** Started building Docker container."
printf "\n*** Please wait... \n***"
docker build -f ./docker/Dockerfile . && \
docker run -it -d \
	--env-file "./.env" \
	--hostname foundry \
	--name foundry \
	--publish 0.0.0.0:8545:8545 \
	--publish 0.0.0.0:3000:3000 \
	--volume $PWD:/opt:rw \
	foundry:latest
if [ $? -ne 0 ]; then
    kill "$PPID"; exit 1;
fi
printf "\n*** Finished building Docker container.\n"

#!/bin/bash

trap "echo; exit" INT
trap "echo; exit" HUP

# assign fallback values for environment variables from .env.example incase
# not declared in .env file. alternative approach is `echo ${X:=$X_FALLBACK}`
source $(dirname "$0")/.env.example
source $(dirname "$0")/.env

printf "\n*** Started building Docker container."
printf "\n*** Please wait... \n***"
# --mount option requires BuildKit
# https://stackoverflow.com/questions/67974976/docker-compose-not-exposing-ports
# https://devops.stackexchange.com/questions/6246/when-would-i-use-docker-composes-service-ports-flag
# https://docs.docker.com/engine/reference/commandline/run/#publish
DOCKER_BUILDKIT=1 docker compose run \
    -p 0.0.0.0:3000:3000 \
    -p 0.0.0.0:8545:8545 \
    --name=foundry --build -it -d foundry
if [ $? -ne 0 ]; then
    kill "$PPID"; exit 1;
fi
printf "\n*** Finished building Docker container.\n"

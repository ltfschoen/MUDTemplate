#!/bin/bash

#================
# check for arguments first. if not arguments provided then
# use environment variables set in Dockerfile or use a fallback value
#================

# args
PROJECT_NAME=$1
FRONTEND_TEMPLATE=$2
LICENSE=$3

# env variables
if [[ ! -z "$PROJECT_NAME" && ! -z "$FRONTEND_TEMPLATE" && ! -z "$LICENSE" ]]; then
    PROJECT_NAME=${PROJECT_NAME}
    FRONTEND_TEMPLATE=${FRONTEND_TEMPLATE}
    LICENSE=${LICENSE}
fi

FALLBACK_PROJECT_NAME=my-project
FALLBACK_FRONTEND_TEMPLATE=vanilla
FALLBACK_LICENSE=MIT
# assign fallback value incase not provided as environment variable
# https://stackoverflow.com/a/4437588/3208553
: ${PROJECT_NAME:=$FALLBACK_PROJECT_NAME}
: ${FRONTEND_TEMPLATE:=$FALLBACK_FRONTEND_TEMPLATE}
: ${LICENSE:=$FALLBACK_LICENSE}
echo "Creating a MUD v2 DApp with name ${PROJECT_NAME} in ${FRONTEND_TEMPLATE} with license ${LICENSE}"

#================
# generate the DApp with the given project name
#================
# create the project in a projects directory that we will create
cd /opt
mkdir -p projects && cd projects
# add `PNPM_HOME="/root/.local/share/pnpm` to ~/.bashrc
pnpm setup
source ~/.bashrc
# set the location of the store metadata
pnpm config set store-dir ~/pnpm
# clear the store metadata and cache
pnpm store prune
pnpm config set global-bin-dir ~/.local/share/pnpm
# create MUD v2 project with the given project name in the projects directory
pnpm create mud@canary ${PROJECT_NAME} --template ${FRONTEND_TEMPLATE} --license ${LICENSE}
# change directory back to project root ready for subsequent commands
cd ${PROJECT_NAME}

#================
# update Vite.js DApp to expose `--host 0.0.0.0` in the project
# and run `export ANVIL_IP_ADDR=0.0.0.0` before running server
#================
# automatically populate the file projects/${PROJECT_NAME}/packages/client/package.json
# by adding `--host 0.0.0.0` so it changes to `"dev": "vite --host 0.0.0.0",` instead of just
# `"dev": "vite",`. note: This exposes the DApp in in the Docker container for access from the
# host machine. See https://github.com/vitejs/vite/issues/12557 and https://github.com/latticexyz/mud/issues/859

HOST=${ANVIL_IP_ADDR}
FALLBACK_HOST="0.0.0.0"
# assign fallback value incase not available as environment variable
: ${HOST:=$FALLBACK_HOST}

NEW_VAL_1="vite --host ${HOST}"
# https://stackoverflow.com/a/66954991/3208553
# search for ./projects/${PROJECT_NAME}/packages/client/package.json
# modify in place the key in the package.json file `"scripts": { "dev": ...`, and change the value from `"vite"`, to `"vite --host 0.0.0.0"`
tmp=$(mktemp)
jq --arg new_value "${NEW_VAL_1}" '.scripts.dev = $new_value' /opt/projects/${PROJECT_NAME}/packages/client/package.json > "$tmp" && mv "$tmp" /opt/projects/${PROJECT_NAME}/packages/client/package.json

pnpm install -g wait-port

NEW_VAL_2="concurrently -n contracts,client -c cyan,magenta \"cd packages/contracts && export ANVIL_IP_ADDR=${HOST} && pnpm run dev\" \"cd packages/client && wait-port localhost:8545 && export ANVIL_IP_ADDR=${HOST} && pnpm run dev\""
tmp2=$(mktemp)
jq --arg new_value_2 "${NEW_VAL_2}" '.scripts.dev = $new_value_2' /opt/projects/${PROJECT_NAME}/package.json > "$tmp2" && mv "$tmp2" /opt/projects/${PROJECT_NAME}/package.json

# ================
# update Vite.js DApp by injecting the snippet of CORS code that is in the file
# content-cors.txt into the file /opt/projects/${PROJECT_NAME}/packages/client/vite.config.ts
# specifically after matching some text like `server: {`
# ================
# search for the file /opt/projects/${PROJECT_NAME}/packages/client/vite.config.ts
# insert the contents of file content-cors.txt into that vite.config.ts file immediately after
# the line that contains the text `server: {` and preserve indentation
# https://unix.stackexchange.com/questions/446527/how-to-insert-file-content-after-a-certain-string-in-a-file
ed -s /opt/projects/${PROJECT_NAME}/packages/client/vite.config.ts <<END_ED
/server: {/r !sed 's/^/    /' /opt/snippets/content-cors.txt
wq
END_ED

#================
# replace Visual Studio Code settings.json file for the DApp with the snippet of settings code
#================
cat /opt/snippets/content-settings.json > /opt/projects/${PROJECT_NAME}/.vscode/settings.json

#================
# run the DApp
#================
cd /opt/projects/${PROJECT_NAME}
pnpm initialize
pnpm install
pnpm run dev

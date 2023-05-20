# MUD v2 DApp Template (using Docker)
============

## Table of Contents

  * [Create New MUD v2 Project](#create-new-project)
  * [Tips to configure Visual Studio Code](#vscode)
  * [Tips for Docker](#docker-tips)
  * [Tips for Lattice, UD, and Foundry](#misc-notes)
  * [Tips when Troubleshooting](#troubleshooting)
  * [Tips with Links](#links-unsorted)

### Create First Project <a id="create-new-project"></a>

* Install [Docker](https://docs.docker.com/get-docker/)
* Fork and/or clone repo.
  ```bash
  git clone https://github.com/ltfschoen/MUDTemplate && cd MUDTemplate
  ```
* Configure DApp by generating a .env file from the .env.example file by following its instructions, if desired.
* Build a Docker image and run a Docker container to create a DApp according to configuration in .env file.
  ```bash
  ./docker/docker.sh
  ```
* Wait... until terminal logs output `[client] Local: http://localhost:3000/`
* Open http://localhost:3000 in web browser to load MUD v2 DApp.

#### Restart Existing Project

* Enter the Docker container shell with the following. It should display a prompt `root@foundry:/opt#`.
  ```bash
  docker exec -it foundry /bin/bash
  ```
* To manually start the MUD v2 DApp switch to the folder of your MUD v2 DApp and run it with:
  ```bash
  cd /opt/projects/my-project
  pnpm run dev
  ```
* Press CTRL+D to exit Docker container shell.

#### Create Additional Projects

* Option 1
  * Run
    ```bash
    docker exec -it foundry ./docker/run.sh <PROJECT_NAME> <TEMPLATE> <LICENSE>
    ```
* Option 2
  * Enter the Docker container shell with the following. It should display a prompt `root@foundry:/opt#`.
    ```bash
    docker exec -it foundry /bin/bash
    ```
  * Create a MUD v2 DApp by running:
    ```bash
    /opt/docker/run.sh <PROJECT_NAME> <TEMPLATE> <LICENSE>
    ```
  * Press CTRL+D to exit Docker container shell.
> Note: See .env.example for possible values to use for `<PROJECT_NAME>`, `<TEMPLATE>`, and `<LICENSE>`.

### Tips to configure Visual Studio Code <a id="vscode"></a>

* Edit my-project/.vscode/settings.json if necessary. Note in ./docker/run.sh we replace its contents with default values in the file ./snippets/content-settings.json

* Verify that the Solidity version value specified in the following files for the following keys is the same (i.e. `0.8.x`). See https://github.com/foundry-rs/foundry/blob/58a272997516046fd745f4b3c37f91d0eb113358/config/src/lib.rs#L179
    * `solc_version` or `solc` ./projects/my-project/packages/contracts/foundry.toml
    * `solidity.compileUsingRemoteVersion` in ./.vscode/settings.json.
    * `solidity.compileUsingRemoteVersion` in ./projects/my-project/.vscode/settings.json.

### Tips for Docker <a id="docker-tips"></a>

* Delete Docker Container 
  ```
  docker stop foundry && docker rm foundry
  ```
* Show Docker Containers
  ```bash
  docker ps -a
  ```
* Show Docker Images
  ```bash
  docker images
  ```
* Previous Docker container
  ```bash
  CONTAINER_ID=$(docker ps -n=1 -q)
  echo $CONTAINER_ID
  ```
* Show IP address. This may be provided as an environment variable with `-e` option
  ```bash
  HOST_IP=$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')
  echo $HOST_IP
  ```
* [Check IP Address macOS](https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach)
  ```bash
  brew install iproute2mac
  ```
* Show bridge IP address
  ```bash
  docker network inspect bridge | grep Gateway
  ```

> Note: It is not necessary to use `--add-host=host.docker.internal:host-gateway` or `expose <PORT>`

> Note: Do not try to use `--network host` on macOS, since _"The host networking driver only works on Linux hosts, and is not supported on Docker Desktop for Mac, Docker Desktop for Windows, or Docker EE for Windows Server."_

### Tips for Lattice, MUD, and Foundry<a id="misc-notes"></a>

#### Definitions

* MODE - is a service that mirrors the state of a Store in a Postgres database. Clients query directly without requiring Ethereum JSON-RPC
* MUD - able to reconstruct the state of Store in the browser using a JSON-RPC or a MODE

#### Faucet

* Faucet tokens request
  * Check the available flags via `--help` like `npx @latticexyz/cli@canary faucet --help`
  * Request Testnet tokens from faucet (FAST way)
    * Run in a project that has the MUD CLI installed as a dev dependency, or via npx like `npx @latticexyz/cli@canary faucet --address <ADDRESS>`. 
  * Request Testnet Tokens from Faucet (SLOW way)
    * Install Foundry `curl -L https://foundry.paradigm.xyz | bash`
    * Install Go
    * Install MUD and request testnet token from faucet
      ```bash
      npm install pnpm --global && \
      git clone https://github.com/latticexyz/mud && \
      cd mud && \
      pnpm install && \
      pnpm run build && \
      cd packages/cli && \
      pnpm install && \
      pnpm run build && \
      node ./dist/mud.js faucet --faucetUrl "https://follower.testnet-chain.linfra.xyz" --address <ADDRESS>
      ```

#### Q&A

* Where is MUD v2 code stored?
  * All the MUD v2 is in the main branch of https://github.com/latticexyz/mud. The tags do not show up since it is released as canary for now, but you can see the versions on https://www.npmjs.com/package/@latticexyz/world?activeTab=versions. To use MUD v2 you would run `pnpm create mud@canary my-project`, since PNPM is preferable over `Yarn`. If store-cache hasn't been published, run `pnpm create mud@2.0.0-alpha.1.93 my-project`:

* Where is the MUD v2 DApp template stored for React?
  * If you choose to use the React template, then changes to the upstream template code occurs here https://github.com/latticexyz/mud/commits/main/templates/react

* How to install additional global MUD v2 dependencies if necessary 
  * Additional dependencies may be required such as: `pnpm install --global concurrently wait-port`

* How to edit the Store config?
  * Use mud.config.ts to edit your Store config directly https://v2.mud.dev/store/installation

* How to update the client/ and contracts/ folder of the MUD v2 DApp to the latest canary version?
  * Run `pnpm mud set-version -v canary` in both the client and contracts package of your project then run `pnpm install` at the root to update your project to the latest canary version

### Tips when Troubleshooting <a id="troubleshooting"></a>

**Please create an issue by clicking [here](https://github.com/ltfschoen/MUDTemplate/issues) and describing the error and upload a screenshot of any errors.**

* How to resolve PNPM global bin directory error
  * If you get the following error when running `pnpm run dev`, then it may be because you previously built the files on a host machine and copied them to a Docker container.
    ```bash
    sh: 1: run-pty: not found
     ELIFECYCLE  Command failed.
    root@docker-desktop:/opt/projects/my-first-mud-project# pnpm install --global run-pty
     ERR_PNPM_NO_GLOBAL_BIN_DIR  Unable to find the global bin directory
    Run "pnpm setup" to create it automatically, or set the global-bin-dir setting, or the PNPM_HOME env variable. The global bin directory should be in the PATH.
    ```
  * Solution is to run `pnpm setup`, which added this to ~/.bashrc:
    ```
    # pnpm
    export PNPM_HOME="/root/.local/share/pnpm"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
    ```
  * Then run the following where `~/.local/share/pnpm` is `$PNPM_HOME`
    ```bash
    source ~/.bashrc
    pnpm config set global-bin-dir ~/.local/share/pnpm
    ```

* How to resolve PNPM dashboard errors
  * Note: If after running DApp with `pnpm run dev`, if you click 1-pnpm dev:client then it should show that it is exposed at http://localhost:3000 and maybe http://172.17.0.2:3000, where 172.17.0.2 is the eth0 IP address shown if you run `ifconfig`
  * If any errors running `pnpm run dev` in the dashboard, then press CTRL+C and then Enter to restart the dashboard and the error should disappear

* How to resolve CORS error `Cross-Origin Request Blocked: The Same Origin Policy disallows reading the remote resource at http://127.0.0.1:8545/. (Reason: CORS request did not succeed). Status code: (null)`
  * Refer to solution here of running with `export ANVIL_IP_ADDR=0.0.0.0 && pnpm run dev` https://github.com/vitejs/vite/discussions/13240#discussioncomment-5934467
  * Note that in the latest MUD v2 updates where they use `concurrently` instead of `run-pty` you would get CORS errors but we use `wait-port` so it only loads the DApp when port 8545 is ready.

* How to configure CORS
  * The CORS configuration may include adding `"proxy": "http://<HOST>:<PORT>",` in a package.json file and updating <your-project>/packages/client/vite.config.ts with a `cors` configuration with keys and values like the below example and replacing <PORT> with an actual port. The below example is not intended to actually work. Refer to Vite.js configuration documentation for more information https://vitejs.dev/config/server-options.html#server-cors, and also https://github.com/http-party/node-http-proxy#options
  * If you change the CORS configuration for the Vite.js DApp frontend by configuring ./projects/my-project/packages/client/vite.config.ts. See https://vitejs.dev/config/server-options.html#server-cors, then run `pnpm store prune` and restart the DApp.
  * Note that you may open all origins with: `cors: { origin: "*", methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'] },`.
    <details><summary>Example CORS code snippet</summary>

      ```json
      cors: {
        // origin: ["ws://127.0.0.1:<PORT>/", "http://127.0.0.1:<PORT>/"],
        origin: "*",
        methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization'],
        credentials: true,
        exposedHeaders: ['Content-Range', 'X-Content-Range'],
        preflightContinue: true,
        optionsSuccessStatus: 204
      },
      hmr: {
        clientPort: <PORT>,
        port: <PORT>,
        overlay: false,
      },
      proxy: {
        '/socket.io': {
          target: 'ws://localhost:<PORT>',
          changeOrigin: true,
          ws: true,
          xfwd: true,
        },
      },
      strictPort: false,
      ```

    </details>

* How to resolve a port being in use?
  * If port 3000 is in use, then find its PID `lsof -i | grep :3000` and then kill it by running `kill -9 <PID>`

### Tips with Links<a id="links-unsorted"></a>

* MUD v1 (legacy)
  * https://mud.dev/guides/getting_started/
* MUD v2
  * Codebase
    * https://github.com/latticexyz/mud
  * Documentation
    * https://v2.mud.dev/what-is-mud
    * https://v2.mud.dev/mode
    * https://v2.mud.dev/store
  * Dependencies
    * Lattice
      * https://www.npmjs.com/package/@latticexyz
* Foundry (Forge, Cast, Anvil, Chisel)
  * Codebase
    * https://github.com/foundry-rs/foundry
  * Documentation
    * https://getfoundry.sh/
    * https://book.getfoundry.sh/
    * https://book.getfoundry.sh/getting-started/installation
* Anvil
  * https://book.getfoundry.sh/anvil/
  * https://book.getfoundry.sh/reference/anvil/
* Example Projects
  * https://github.com/latticexyz/emojimon
  * https://github.com/latticexyz/opcraft
  * List of MUD games https://community.mud.dev/MUD-Projects-2996171a4b4b472b9df557f8bfdd3c49
  * MUD unity game https://github.com/emergenceland/mud-template-unity

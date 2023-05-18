# MUD v2 DApp (using Docker)
============

## Table of Contents

  * [Create New MUD v2 Project](#create-new-project)
  * [Configure Visual Studio Code](#vscode)
  * [Docker Tips](#docker-tips)
  * [Miscellaneous Notes for Lattice, UD, and Foundry](#misc-notes)
  * [Troubleshooting](#troubleshooting)
  * [Links Unsorted](#links-unsorted)

### Create New Project <a id="create-new-project"></a>

* Install [Docker](https://docs.docker.com/get-docker/)
* Fork and/or clone repo. If you fork then replace with your fork link below 
```
git clone https://github.com/ltfschoen/MUDTest
cd MUDTest
```
* Run a Docker container:
```bash
touch .env && cp .env.example .env
./docker.sh
docker ps -a
```
* Enter the Docker container shell
```bash
docker exec -it foundry /bin/bash
```
* Run the following in Docker container. Change `my-project` to your desired project name.
```bash
mkdir -p projects && cd projects
pnpm setup
source ~/.bashrc
pnpm config set store-dir ~/pnpm
pnpm store prune
pnpm config set global-bin-dir ~/.local/share/pnpm
pnpm create mud@canary my-project
cd my-project
rm -rf node_modules
```
* Manually modify the file projects/my-project/packages/client/package.json by adding `--host 0.0.0.0` so it changes to `"dev": "vite --host 0.0.0.0",` instead of just `"dev": "vite",`. 
  * Note: This exposes the DApp in in the Docker container for access from the host machine. See https://github.com/vitejs/vite/issues/12557 and https://github.com/latticexyz/mud/issues/859
* Run the DApp
```bash
pnpm initialize
pnpm install
export ANVIL_IP_ADDR=0.0.0.0 && pnpm run dev
```
* Go to http://localhost:3000
* View browser console logs and inspect Docker container terminal to check for errors

### Configure Visual Studio Code <a id="vscode"></a>

* In my-project/.vscode/settings.json, update it to be: 
```json
{
  "editor.formatOnSave": true,
  "[solidity]": {
    "editor.defaultFormatter": "JuanBlanco.solidity" 
  },
  "solidity.compileUsingRemoteVersion": "v0.8.13",
  "solidity.formatter": "forge",
  "solidity.monoRepoSupport": true,
  "solidity.packageDefaultDependenciesContractsDirectory": "./node_modules",
  "solidity.packageDefaultDependenciesDirectory": "./packages/contracts"
}
```

### Docker Tips <a id="docker-tips"></a>

* Delete Docker Container 
```
docker stop foundry && docker rm foundry
```
* Previous Docker container
```
CONTAINER_ID=$(docker ps -n=1 -q)
echo $CONTAINER_ID
```
* Show IP address. This may be provided as an environment variable with `-e` option
```
HOST_IP=$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')
echo $HOST_IP
```
* [Check IP Address macOS](https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach)
```
brew install iproute2mac
```
* Show bridge IP address
```bash
docker network inspect bridge | grep Gateway
```
* Note: It is not necessary to use `--add-host=host.docker.internal:host-gateway` or `expose <PORT>`
* Do not try to use `--network host` on macOS, since _"The host networking driver only works on Linux hosts, and is not supported on Docker Desktop for Mac, Docker Desktop for Windows, or Docker EE for Windows Server."_

### Miscellaneous Notes for Lattice, MUD, and Foundry<a id="misc-notes"></a>

* Definitions
    * MODE - is a service that mirrors the state of a Store in a Postgres database. Clients query directly without requiring Ethereum JSON-RPC
    * MUD - able to reconstruct the state of Store in the browser using a JSON-RPC or a MODE

* Faucet tokens request
  * Check the available flags via `--help` like `npx @latticexyz/cli@canary faucet --help`
  * Request Testnet tokens from faucet (FAST way)
    * Run in a project that has the MUD CLI installed as a dev dependency, or via npx like `npx @latticexyz/cli@canary faucet --address <ADDRESS>`. 
  * Request Testnet Tokens from Faucet (SLOW way)
    * Install Foundry `curl -L https://foundry.paradigm.xyz | bash`
    * Install Go
    * Install MUD and request testnet token from faucet
      ```
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

* Other notes:
  * If you choose to use the React template, then changes to the upstream template code occurs here https://github.com/latticexyz/mud/commits/main/templates/react
  * In my-project/packages/contracts/foundry.toml, update `solc_version` value to match that `solidity.compileUsingRemoteVersion`. See https://github.com/foundry-rs/foundry/blob/58a272997516046fd745f4b3c37f91d0eb113358/config/src/lib.rs#L179
  * Note: Node.js v18.x is supported
  * Note: Additional dependencies may be required such as: `pnpm install --global concurrently wait-port`
  * All the MUD v2 is in the main branch of https://github.com/latticexyz/mud. The tags do not show up since it is released as canary for now, but you can see the versions on https://www.npmjs.com/package/@latticexyz/world?activeTab=versions. To use MUD v2 you would run `pnpm create mud@canary my-project`, since PNPM is preferable over `Yarn`. If store-cache hasn't been published, run `pnpm create mud@2.0.0-alpha.1.93 my-project`:
  * Use mud.config.ts to edit your Store config directly https://v2.mud.dev/store/installation
  * Note: Run `pnpm mud set-version -v canary` in both the client and contracts package of your project then run `pnpm install` at the root to update your project to the latest canary version
  * If necessary, configure CORS for the Vite.js DApp frontend by configuring ./projects/my-project/packages/client/vite.config.ts. See https://vitejs.dev/config/server-options.html#server-cors, then run `pnpm store prune` and restart the DApp. Open to all origins with: `cors: { origin: "*", methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'] },`.
  * CORS configuration may include adding `"proxy": "http://<HOST>:<PORT>",` in a package.json file and updating <your-project>/packages/client/vite.config.ts with a `cors` configuration with keys and values like the below example and replacing <PORT> with an actual port. The below example is not intended to actually work. Refer to Vite.js configuration documentation for more information https://vitejs.dev/config/server-options.html#server-cors, and also https://github.com/http-party/node-http-proxy#options
    ```
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

### Troubleshooting <a id="troubleshooting"></a>

* PNPM global bin directory error
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

* PNPM dashboard errors
  * Note: If after running DApp with `pnpm run dev`, if you click 1-pnpm dev:client then it should show that it is exposed at http://localhost:3000 and maybe http://172.17.0.2:3000, where 172.17.0.2 is the eth0 IP address shown if you run `ifconfig`
  * If any errors running `pnpm run dev` in the dashboard, then press CTRL+C and then Enter to restart the dashboard and the error should disappear

* CORS error `Cross-Origin Request Blocked: The Same Origin Policy disallows reading the remote resource at http://127.0.0.1:8545/. (Reason: CORS request did not succeed). Status code: (null)`
  * Refer to solution here of running with `export ANVIL_IP_ADDR=0.0.0.0 && pnpm run dev` https://github.com/vitejs/vite/discussions/13240#discussioncomment-5934467

### Links Unsorted <a id="links-unsorted"></a>

* MUD v1 (legacy)
  * https://mud.dev/guides/getting_started/
* MUD v2
  * https://github.com/latticexyz/mud
  * https://v2.mud.dev/what-is-mud
  * https://v2.mud.dev/mode
  * https://v2.mud.dev/store
* Lattice
  * https://www.npmjs.com/package/@latticexyz
* Foundry
  * https://getfoundry.sh/
  * https://github.com/foundry-rs/foundry
  * https://book.getfoundry.sh/
  * https://book.getfoundry.sh/getting-started/installation
* Forge, Cast, Anvil
  * https://book.getfoundry.sh/anvil/
  * https://book.getfoundry.sh/reference/anvil/
* Example Projects
  * https://github.com/latticexyz/emojimon
  * https://github.com/latticexyz/opcraft

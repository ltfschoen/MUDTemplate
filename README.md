# MUD v2 DApp (using Docker)

## Setup

```bash
touch .env && cp .env.example .env
./docker.sh
docker ps -a
docker exec -it foundry /bin/bash
```

* Note: Node.js v18.x is supported
* Run the following in Docker container
```bash
mkdir projects && cd projects
pnpm config set store-dir ~/pnpm
pnpm create mud@canary my-project
cd my-project
rm -rf node_modules
pnpm install --global run-pty
pnpm install
```
* FIXME - CORS configuration
  * At this stage to avoid a CORS issue accessing the DApp in the Docker container from the host machine (see https://github.com/latticexyz/mud/issues/860), it is necessary to do https://github.com/latticexyz/mud/issues/860#issuecomment-1550812789 by editing my-project/node_modules/.pnpm/vite@4.2.1/node_modules/vite/dist/client/client.mjs by changing the line `const socketHost = ${__HMR_HOSTNAME__ || importMetaUrl.hostname}:${hmrPort || importMetaUrl.port}${__HMR_BASE__};` to instead be `const socketHost = '127.0.0.1:8545';`. Relates to https://github.com/vitejs/vite/issues/652 that hasn't been resolved yet and possibly should be re-opened
  * It is also necessary to modify packages/client/vite.config.ts. See the Vitejs docs https://vitejs.dev/config/server-options.html#server-cors
  ```bash
  export default defineConfig({
    ...
    server: {
    ...
    cors: {
      # origin: [/localhost:8545$/, /localhost:3000$/, /127.0.0.1:8545$/],
      origin: "*",
      methods: ['GET', HEAD, 'PUT', 'PATCH', 'POST', 'DELETE'],
      allowedHeaders: ['Content-Type', 'Authorization']
    },
    ...
    },
    ...
  })
  ```
* Also required to access the DApp in the Docker container from the host machine is to modify its package.json file manually by adding `--host 0.0.0.0` so it changes to `"dev:client": "pnpm --filter 'client' run dev --host 0.0.0.0",` instead of just `"dev:client": "pnpm --filter 'client' run dev",` (see https://github.com/latticexyz/mud/issues/859).
* After doing that continue...
```bash
pnpm initialize
pnpm run dev
```
* Note: If you click 1-pnpm dev:client then it should show that it is exposed at http://localhost:3000 and maybe http://172.17.0.2:3000, where 172.17.0.2 is the eth0 IP address shown if you run `ifconfig`
* If any errors running `pnpm run dev` in the dashboard, then press CTRL+C and then Enter to restart the dashboard and the error should disappear
* Go to http://localhost:3000

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
* In my-project/packages/contracts/foundry.toml, update `solc_version` value to match that `solidity.compileUsingRemoteVersion`. See https://github.com/foundry-rs/foundry/blob/58a272997516046fd745f4b3c37f91d0eb113358/config/src/lib.rs#L179

## Miscellaneous

### Foundry

#### Links

* Misc
  * https://getfoundry.sh/
  * https://github.com/foundry-rs/foundry
  * https://book.getfoundry.sh/
  * https://book.getfoundry.sh/getting-started/installation
* Forge, Cast, Anvil
  * https://book.getfoundry.sh/anvil/
  * https://book.getfoundry.sh/reference/anvil/

### MUD

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
  * All the MUD v2 is in the main branch of https://github.com/latticexyz/mud. The tags do not show up since it is released as canary for now, but you can see the versions on https://www.npmjs.com/package/@latticexyz/world?activeTab=versions. To use MUD v2 you would run `pnpm create mud@canary my-project`, since PNPM is preferable over `Yarn`. If store-cache hasn't been published, run `pnpm create mud@2.0.0-alpha.1.93 my-project`:
  * Use mud.config.ts to edit your Store config directly https://v2.mud.dev/store/installation
  * Note: Run `pnpm mud set-version -v canary` in both the client and contracts package of your project then run `pnpm install` at the root to update your project to the latest canary version

* Other notes
  * https://github.com/latticexyz/emojimon/pull/7/files `mud tsgen --configPath mud.config.mts --out ../client/src/mud`

#### Links

* MUD v1 (legacy)
  * https://mud.dev/guides/getting_started/
* MUD v2
  * https://github.com/latticexyz/mud
  * https://v2.mud.dev/what-is-mud
  * https://v2.mud.dev/mode
  * https://v2.mud.dev/store

### Docker

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
* Show bridge IP address
```bash
docker network inspect bridge | grep Gateway
```
* Note: It is not necessary to use `--add-host=host.docker.internal:host-gateway` or `expose <PORT>`
* Do not try to use `--network host` on macOS, since _"The host networking driver only works on Linux hosts, and is not supported on Docker Desktop for Mac, Docker Desktop for Windows, or Docker EE for Windows Server."_

### Networking
* [Check IP Address macOS](https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach)
```
brew install iproute2mac
```

# coinjoin-backend
Docker image running multiple services: bitcoind, blockbook, wasabi-wallet and wasabi-backend

## Building
The command `make`
  * clones the WasabiWallet,
  * builds a docker image called `coinjoin-backend-image`,
  * creates a docker container called `coinjoin-backend-container`.

## Running
The docker container is started with `make start` and stopped with `make stop`. The container doesn't discard its state when stopped.

The container runs a RegTest with the following services on the address 127.0.0.1:

| Server                  | Protocol | Port  | User | Password |
|-------------------------|----------|-------|------|----------|
| Bitcoin knots           | P2P      | 18444 |      |          |
| Bitcoin knots           | RPC      | 18443 | rpc  | rpc      |
| Bitcoin core            | P2P      | 28444 |      |          |
| Bitcoin core            | RPC      | 28443 | rpc  | rpc      |
| Blockbook               | HTTP     | 19121 |      |          |
| Blockbook               | RPC      | 28443 |      |          |
| Faucet                  | HTTP     | 8080  |      |          |
| Wabisabi proxy          | HTTP     | 8081  |      |          |
| WalletWasabi backend    | REST API | 37127 |      |          |
| WalletWasabi client     | REST API | 37128 |      |          |

The command `make create-container` rebuilds the container which resets the network.

## Connecting to WasabiWallet GUI
  * Run the WasabiWallet GUI.
  * Go to settings of the GUI and
    * turn off network encryption (TOR),
    * set network to RegTest,
    * set bitcoin P2P Endpoint to 127.0.0.1:18444.
  * Restart the GUI.
  * Open http://127.0.0.1:8080 in your browser.
  * Send yourself money.


## Proxy

For development in browser environment proxy accepts preflight `OPTIONS` requests and overrides `Access-Control-Allow-Origin` header

### Proxy endpoints:
- WabiSabi backend http://localhost:8081/backend
- WabiSabi coordinator http://localhost:8081/backend/wabisabi
- WabiSabi client http://localhost:8081/client


## Running WasabiWallet from docker
`sudo xhost +`

`docker run -it --net host -v "/tmp/.X11-unix/":"/tmp/.X11-unix/" -e DISPLAY="${DISPLAY}" coinjoin-backend-image "run-environment && wasabi-wallet"`

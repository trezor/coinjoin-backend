# Building
The command `make`
  * clones the WassabiWallet,
  * builds a docker image called `coinjoin-backend-image`,
  * creates a docker container called `coinjoin-backend-container`.

# Running
The docker container is started with `make start` and stopped with `make stop`. The container doesn't discard its state when stopped.

The container runs a RegTest with the following services on the address 127.0.0.1:

| Server               | Protocol | Port  | User | Password |
|----------------------|----------|-------|------|----------|
| Bitcoin knots        | P2P      | 18444 |      |          |
| Bitcoin knots        | RPC      | 18443 | rpc  | rpc      |
| Bitcoin core         | P2P      | 28444 |      |          |
| Bitcoin core         | RPC      | 28443 | rpc  | rpc      |
| Blockbook            | HTTP     | 8030  |      |          |
| Faucet               | HTTP     | 8000  |      |          |
| WalletWasabi backend | REST API | 37127 |      |          |

The command `make create-container` rebuilds the container which resets the network.

# Connecting to WasabiWallet GUI
  * Run the WasabiWallet GUI.
  * Go to settings of the GUI and
    * turn off network encryption (TOR),
    * set network to RegTest,
    * set bitcoin P2P Endpoint to 127.0.0.1:18444.
  * Restart the GUI.
  * Open http://127.0.0.1:8000 in your browser.
  * Send yourself money.

FROM debian:buster-slim
RUN apt-get update

# Install python
RUN apt-get install -y python3 python3-pip python3-requests
RUN pip3 install ecdsa==0.16.1

# Install dotnet
RUN apt-get install -y wget
RUN wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN apt-get install -fy /packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb
RUN apt-get update
RUN apt-get install -y dotnet-sdk-6.0 dotnet-runtime-6.0

# Install bitcoin core, blockbook and bitcoin knots
COPY packages/ /packages/
RUN apt install -fy /packages/backend-bitcoin-regtest_22.0-satoshilabs-1_amd64.deb
RUN apt install -fy /packages/blockbook-bitcoin-regtest_0.3.6_amd64.deb
RUN tar -xzf /packages/bitcoin-22.0.knots20211108-x86_64-linux-gnu.tar.gz --one-top-level=/opt/bitcoin-knots/ --strip-components=1

# Install WalletWasabi
RUN apt-get install -y libx11-dev libice-dev libsm-dev libfontconfig1 
COPY vendor/WalletWasabi /opt/WalletWasabi
RUN cd /opt/WalletWasabi/ && dotnet build

# Install faucet
COPY faucet /opt/faucet

# Copy configuration
COPY configuration/bitcoin-core/ /opt/coins/nodes/bitcoin_regtest/
COPY configuration/bitcoin-knots/ /opt/bitcoin-knots/config/
COPY configuration/blockbook/ /opt/coins/blockbook/bitcoin_regtest/config
COPY configuration/wallet-wasabi/ /root/.walletwasabi/

RUN mkdir /opt/bitcoin-knots/data

# Install scripts
COPY scripts/ /opt/bin/
ENV PATH="/opt/bin/:${PATH}"

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["run-environment && sleep infinity"]
RUN mkdir /mnt/shared/

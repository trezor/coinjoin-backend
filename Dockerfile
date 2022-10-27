FROM debian:bullseye-slim
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

# Install bitcoin knots
RUN mkdir /packages
RUN wget https://bitcoinknots.org/files/23.x/23.0.knots20220529/bitcoin-23.0.knots20220529-x86_64-linux-gnu.tar.gz -O /packages/bitcoin-23.0.knots20220529-x86_64-linux-gnu.tar.gz
RUN tar -xzf /packages/bitcoin-23.0.knots20220529-x86_64-linux-gnu.tar.gz --one-top-level=/opt/bitcoin-knots/ --strip-components=1
RUN rm -rf /packages

# Install WalletWasabi
RUN apt-get install -y libx11-dev libice-dev libsm-dev libfontconfig1
COPY vendor/WalletWasabi /opt/WalletWasabi
RUN cd /opt/WalletWasabi/ && dotnet build

# Copy configuration
COPY configuration/bitcoin-knots/ /opt/bitcoin-knots/config/
COPY configuration/wallet-wasabi/ /root/.walletwasabi/

RUN mkdir /opt/bitcoin-knots/data

# Install scripts
COPY scripts/ /opt/bin/
ENV PATH="/opt/bin/:${PATH}"

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["run-environment-testnet && sleep infinity"]

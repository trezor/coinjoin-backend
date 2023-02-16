FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
  # Python
    python3 python3-pip python3-requests \
  # .NET dependencies
    libc6 libgcc1 libgssapi-krb5-2 libssl1.1 libstdc++6 zlib1g libicu67\
  # Other tools
    wget curl

RUN pip3 install ecdsa==0.16.1

# Install dotnet
RUN curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 7.0 --install-dir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet


# Install bitcoin core, blockbook and bitcoin knots
ARG TARGETPLATFORM
RUN mkdir /packages
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi \
  && wget https://data.trezor.io/dev/blockbook/builds/backend-bitcoin-regtest_24.0.1-satoshilabs-1_${ARCHITECTURE}.deb -O /packages/backend-bitcoin-regtest_24.0.1-satoshilabs-1_${ARCHITECTURE}.deb \
  && wget https://data.trezor.io/dev/blockbook/builds/blockbook-bitcoin-regtest_0.4.0_${ARCHITECTURE}.deb -O /packages/blockbook-bitcoin-regtest_0.4.0_${ARCHITECTURE}.deb \
  && apt install -fy /packages/backend-bitcoin-regtest_24.0.1-satoshilabs-1_${ARCHITECTURE}.deb \
  && apt install -fy /packages/blockbook-bitcoin-regtest_0.4.0_${ARCHITECTURE}.deb

RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCHITECTURE_KNOTS=x86_64; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCHITECTURE_KNOTS=aarch64; else ARCHITECTURE_KNOTS=x86_64; fi \
  && wget https://bitcoinknots.org/~luke-jr/.RISKY/programs/bitcoin/files/bitcoin-knots/23.x/23.0.knots20220529/bitcoin-23.0.knots20220529-${ARCHITECTURE_KNOTS}-linux-gnu.tar.gz -O /packages/bitcoin-23.0.knots20220529-${ARCHITECTURE_KNOTS}-linux-gnu.tar.gz \
  && tar -xzf /packages/bitcoin-23.0.knots20220529-${ARCHITECTURE_KNOTS}-linux-gnu.tar.gz --one-top-level=/opt/bitcoin-knots/ --strip-components=1

RUN rm -rf /packages

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

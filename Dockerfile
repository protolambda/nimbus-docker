FROM debian:bullseye-slim AS build

SHELL ["/bin/bash", "-c"]

RUN apt-get -qq update \
 && apt-get -qq -y install build-essential make wget libpcre3-dev git &>/dev/null \
 && apt-get -qq clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD config.yaml /root/config.yaml
ADD nim-beacon-chain /root/nim-beacon-chain

RUN cd /root \
 && cd nim-beacon-chain \
 && { make V=1 || true; } \
 && make V=1 -j$(nproc) update \
 && make V=1 deps

ARG NETWORK_NIM_FLAGS
ARG MARCH_NIM_FLAGS

# Note: -d:insecure allows the insecure http server to run for API support, but it's buggy and insecure.
RUN cd /root/nim-beacon-chain \
 && make V=1 -j$(nproc) update \
 && make V=1 LOG_LEVEL=TRACE NIMFLAGS="-d:insecure -d:ETH2_SPEC=v0.12.1 -d:BLS_ETH2_SPEC=v0.12.x --verbosity:1 --hints:off -d:usePcreHeader --passL:\"-lpcre\" -d:release --d:const_preset=/root/config.yaml ${NETWORK_NIM_FLAGS} ${MARCH_NIM_FLAGS}" beacon_node

# --------------------------------- #
# Starting new image to reduce size #
# --------------------------------- #
FROM debian:bullseye-slim as deploy

SHELL ["/bin/bash", "-c"]

RUN apt-get -qq update \
 && apt-get -qq -y install libpcre3 psmisc &>/dev/null \
 && apt-get -qq clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# "COPY" creates new image layers, so we cram all we can into one command
COPY --from=build /root/nim-beacon-chain/build/beacon_node /usr/bin/

ENTRYPOINT ["/usr/bin/beacon_node"]


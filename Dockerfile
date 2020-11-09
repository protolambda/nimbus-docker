FROM debian:buster-slim AS build

SHELL ["/bin/bash", "-c"]

# use gcc 10.2.0-15 or older, see https://github.com/status-im/nimbus-eth2/issues/1970#issuecomment-723736321
RUN apt-get -qq update \
 && apt-get -qq -y install build-essential libpcre3-dev git &>/dev/null \
 && apt-get -qq clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# TODO: use volumes or bind-mounts instead
ADD nimbus-eth2 /root/nimbus-eth2

# It's up to you to run `git pull; make update` in "nimbus-eth2", outside the container,
# preferably in the "devel" branch.

# Note: -d:insecure allows the insecure http server to run for API support, but it's buggy and insecure.
# We need to run `make update` again because some absolute paths changed.
RUN cd /root/nimbus-eth2 \
 && make -j$(nproc) update \
 && make -j$(nproc) LOG_LEVEL="TRACE" NIMFLAGS="-d:insecure" beacon_node \
 && make -j$(nproc) LOG_LEVEL="TRACE" NIMFLAGS="-d:insecure" validator_client

# alternatively:
# && make -j$(nproc) LOG_LEVEL=TRACE NIMFLAGS="-d:insecure -d:ETH2_SPEC=v0.12.1 -d:BLS_ETH2_SPEC=v0.12.x -d:const_preset=/root/config.yaml" validator_client

# --------------------------------- #
# Starting new image to reduce size #
# --------------------------------- #
FROM debian:buster-slim as deploy

SHELL ["/bin/bash", "-c"]

RUN apt-get -qq update \
 && apt-get -qq -y install libpcre3 psmisc &>/dev/null \
 && apt-get -qq clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# "COPY" creates new image layers, so we cram all we can into one command
COPY --from=build /root/nimbus-eth2/build/beacon_node /usr/bin/
COPY --from=build /root/nimbus-eth2/build/validator_client /usr/bin/

RUN mkdir /data

STOPSIGNAL SIGINT

# Caller can use either 'beacon_node' or 'validator_client' binary

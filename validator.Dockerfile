FROM debian:bullseye-slim AS build

SHELL ["/bin/bash", "-c"]

RUN apt-get -qq update \
 && apt-get -qq -y install build-essential libpcre3-dev git &>/dev/null \
 && apt-get -qq clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# TODO: use volumes or bind-mounts instead
ADD nim-beacon-chain /root/nim-beacon-chain

ADD config.yaml /root/config.yaml

# It's up to you to run `git pull; make update` in "nim-beacon-chain", outside the container,
# preferably in the "devel" branch.

# Note: -d:insecure allows the insecure http server to run for API support, but it's buggy and insecure.
# We need to run `make update` again because some absolute paths changed.
RUN cd /root/nim-beacon-chain \
 && make -j$(nproc) update \
 && make -j$(nproc) LOG_LEVEL=TRACE NIMFLAGS="-d:insecure -d:ETH2_SPEC=v0.12.1 -d:BLS_ETH2_SPEC=v0.12.x -d:const_preset=/root/config.yaml" validator_client


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
COPY --from=build /root/nim-beacon-chain/build/validator_client /usr/bin/

STOPSIGNAL SIGINT

ENTRYPOINT ["/usr/bin/validator_client"]


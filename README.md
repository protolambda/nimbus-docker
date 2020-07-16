# Nimbus Beacon docker fork

To get Nimbus running in Docker, from arbitrary source checkout.

Custom configuration can be added with `-d:const_preset=/root/config.yaml` in the dockerfile.

Adapted from the Nimbus Dockerfile.

*Experimental software, use at own risk*

Clone/copy your version of https://github.com/status-im/nim-beacon-chain into `nim-beacon-chain` directory to get started.

Example usage:

```bash
cd nim-beacon-chain
git checkout devel
git pull
make -j8 update
cd ..
DOCKER_BUILDKIT=1 docker build -t nimbus-altona --progress=plain .
docker run --rm --name nimbus-bn nimbus-altona beacon_node --network=altona <various options>
docker run --rm --name nimbus-vc nimbus-altona validator_client <various options>

# stopping it from another terminal
docker stop nimbus-bn
docker stop nimbus-vc

# cleanup
docker builder prune -f
docker image prune -f
```



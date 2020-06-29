# Nimbus Beacon docker fork

To get Nimbus running in Docker, from arbitrary source checkout, and with custom testnet config.

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
docker run --rm --name nimbus-altona nimbus-altona <various options>

# stopping it from another terminal
docker stop nimbus-altona

# cleanup
docker builder prune -f
docker image prune -f
```

Similarly, you can build `validator.Dockerfile` for a validator client (super experimental).


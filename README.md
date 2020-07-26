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
docker build -t protolambda/nim_beacon_node:latest --progress=plain .
```



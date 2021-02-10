# Nimbus Beacon docker fork

To get Nimbus running in Docker, from arbitrary source checkout.

Custom configuration can be added with `-d:const_preset=/root/config.yaml` in the dockerfile.

Adapted from the Nimbus Dockerfile.

*Experimental software, use at own risk*

Git clone nimbus into `./nimbus-eth2`

Example usage:

```bash
cd nimbus-eth2
git checkout stable
git pull
make -j8 update
cd ..
docker build -t protolambda/nimbus:latest .
```



#!/bin/bash
path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
source $path/env

docker pull blockcast/cdn_gateway_go:stable
cd $WORKDIR
docker compose --profile managed up -d --force-recreate

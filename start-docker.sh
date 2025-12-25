#!/bin/bash
path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
cd $path
source $path/env

docker stop blockcastd control-proxy beacond
docker rm blockcastd control-proxy beacond
bash start.sh

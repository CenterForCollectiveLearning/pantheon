#!/bin/bash
# simultaneous_last_step.sh: Simultaneously remove old bundle, move bundle into new directory, copy over mongodb, and restart ports

sudo kill $(ps aux | grep pantheon_bundle | awk '{print$2}')
MONGO_URL=mongodb://localhost:27017/meteor
ROOT_URL=http://localhost

echo "Running application"
for i in {0..50..10}
do
    PORT=3$(printf %03d $i)
    echo Running server on port: $PORT
    sudo PORT=$PORT MONGO_URL=$MONGO_URL ROOT_URL=$ROOT_URL node ../pantheon_bundle/bundle/main.js > pantheon.log &
done
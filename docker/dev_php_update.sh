#!/bin/bash

# screen docker run --name mirnaselector-dev -p 28888:80 -p 28889:8888 mirnaselector
docker cp /home/konrad/snorlax/miRNAselector/static/. mirnaselector-dev:/root/miRNAselector/miRNAselector/static/
docker cp /home/konrad/snorlax/miRNAselector/docker/. mirnaselector-dev:/root/miRNAselector/miRNAselector/docker/
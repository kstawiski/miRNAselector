#!/bin/bash

# screen docker run --name mirnaselector -p 28888:80 -p 28889:8888 mirnaselector
docker cp /home/konrad/snorlax/miRNAselector/static/. mirnaselector:/miRNAselector/miRNAselector/static/
docker cp /home/konrad/snorlax/miRNAselector/docker/. mirnaselector:/miRNAselector/miRNAselector/docker/
docker cp /home/konrad/snorlax/miRNAselector/templetes/. mirnaselector:/miRNAselector/miRNAselector/templetes/

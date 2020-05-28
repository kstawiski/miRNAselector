#!/bin/bash
docker run --gpus all --rm --name mirnaselector -d -p 28888:80 -v /home/konrad/:/miRNAselector/host/ kstawiski/mirnaselector-gpu

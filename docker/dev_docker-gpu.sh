#!/bin/bash
nvidia-docker run --name mirnaselector -d -p 28888:80 -v /home/konrad/:/miRNAselector/host/ mirnaselector-gpu

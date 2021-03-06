#!/bin/bash




# must start in ./docker/ dir
# docker login --username=kstawiski
docker builder prune
docker image prune -a

docker build --rm --force-rm -f ../Dockerfile.gpu -t mirnaselector-gpu ../
# if low memory machine: docker build --rm --force-rm -f ../Dockerfile.workflow -t mirnaselector ../
docker tag mirnaselector-gpu:latest kstawiski/mirnaselector-gpu:latest
docker push kstawiski/mirnaselector-gpu

docker build --rm --force-rm -t mirnaselector ../
# if low memory machine: docker build --rm --force-rm -f ../Dockerfile.workflow -t mirnaselector ../ 
docker tag mirnaselector:latest kstawiski/mirnaselector:latest
docker push kstawiski/mirnaselector

# for google cloud
# docker tag kstawiski/mirnaselector:latest gcr.io/konsta/mirnaselector:latest
# docker push gcr.io/konsta/mirnaselector
docker pull kstawiski/mirnaselector


docker run --name mirnaselector --rm -d -p 28888:80 -v /boot/temp/:/tmp/ -v /home/konrad/:/miRNAselector/host/ kstawiski/mirnaselector


# RAMDISK:
# sudo mkdir /mnt/ramdisk
# sudo mount -t tmpfs -o size=128g tmpfs /mnt/ramdisk

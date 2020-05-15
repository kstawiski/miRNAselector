#!/bin/bash

# must start in ./docker/ dir
# docker login --username=kstawiski
docker builder prune
docker image prune -a
docker build --rm --force-rm -t mirnaselector ../
# if low memory machine: docker build --rm --force-rm -f ../Dockerfile.workflow -t mirnaselector ../ 
docker tag mirnaselector:latest kstawiski/mirnaselector:latest
docker push kstawiski/mirnaselector

# for google cloud
# docker tag kstawiski/mirnaselector:latest gcr.io/konsta/mirnaselector:latest
# docker push gcr.io/konsta/mirnaselector
docker pull kstawiski/mirnaselector

docker run --name mirnaselector --rm -d -p 28888:80 kstawiski/mirnaselector # debug container

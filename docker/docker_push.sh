#!/bin/bash

# must start in ./docker/ dir
docker login --username=kstawiski
docker builer prune
# docker image prune -a
docker build -t mirnaselector ../
docker tag mirnaselector:latest kstawiski/mirnaselector:latest
docker push kstawiski/mirnaselector

# for google cloud
# docker tag kstawiski/mirnaselector:latest gcr.io/konsta/mirnaselector:latest
# docker push gcr.io/konsta/mirnaselector
docker pull kstawiski/mirnaselector

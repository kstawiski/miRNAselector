#!/bin/bash

# must start in ./docker/ dir
docker login --username=kstawiski
docker builer prune
# docker image prune -a
docker build -t mirnaselector ../
docker tag mirnaselector:latest kstawiski/mirnaselector:latest
docker push kstawiski/mirnaselector

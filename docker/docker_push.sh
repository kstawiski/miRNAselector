#!/bin/bash
docker build -t mirnaselector ../
docker login --username=kstawiski
docker tag mirnaselector:latest kstawiski/mirnaselector:latest
docker push kstawiski/mirnaselector

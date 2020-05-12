![](vignettes/logo.png)

# miRNAselector package

Authors: Konrad Stawiski (konrad@konsta.com.pl), Marcin Kaszkowiak

## Installation

**[OPTION 1] Docker version (recommended):**

If you do not know how docker works go to [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/).

Our public docker image: [`kstawiski/mirnaselector`](https://hub.docker.com/r/kstawiski/mirnaselector).

Quick-start command: `docker run --name mirnaselector -p 28888:80 kstawiski/mirnaselector` and go to `http://127.0.0.1:28888` for GUI. You can change `28888` to the port you desire.

Pearls:

- Docker version contains web-based GUI allowing for easy implementation of the pipeline.
- We assure the correct functionality only on docker version.
- Docker container is based on configured ubuntu

**[OPTION 2] Installation in your local R enviorment:**

Run `vignettes/setup.R` script to install nessesary libraries.

## Tutorial

- Basic functionality: https://htmlpreview.github.io/?https://github.com/kstawiski/miRNAselector/blob/master/static/Tutorial.html

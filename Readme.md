![](vignettes/logo.png)

# miRNAselector package

Authors: Konrad Stawiski (konrad@konsta.com.pl), Marcin Kaszkowiak

## Installation

**[OPTION 1] Docker version (recommended):**

Docker image: https://hub.docker.com/r/kstawiski/mirnaselector

Starting command: `docker run --name mirnaselector-dev -p 28888:80 -p 28889:8888 mirnaselector`

Pearls:

- Docker version contains GUI allowing for easy implementation of the pipeline. If you use to run this docker image on your own comupter with command above - go to http://127.0.0.1:28888 for GUI.
- We assure the correct functionality only on docker version.

**[OPTION 2] Installation in your local R enviorment:**

Run `vignettes/setup.R` script to install nessesary libraries.

## Tutorial

- Basic functionality: https://htmlpreview.github.io/?https://github.com/kstawiski/miRNAselector/blob/master/static/Tutorial.html

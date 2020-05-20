# pkgdown &lt;img src="vignettes/logo.png" align="right" /&gt;

![vignettes/logo.png]

# miRNAselector

![Docker](https://github.com/kstawiski/miRNAselector/workflows/Docker/badge.svg) ![R package and environment](https://github.com/kstawiski/miRNAselector/workflows/R%20package%20and%20environment/badge.svg)

Environment, docker-based application and R package for biomarker signiture selection from high-throughput experiments. Initially developed for miRNA-seq.

Go to https://kstawiski.github.io/miRNAselector/ for more details.

## Quick start:

Docker:

```
docker run --name mirnaselector -p 28888:80 kstawiski/mirnaselector
```

R package:

```
library("devtools")
source_url("https://raw.githubusercontent.com/kstawiski/miRNAselector/master/vignettes/setup.R")
install_github("kstawiski/miRNAselector", force = T)
library(keras)
install_keras()
library(miRNAselector)
ks.setup()
```

## Authors:

By Konrad Stawiski (konrad@konsta.com.pl) and Marcin Kaszkowiak.

Department of Biostatistics and Translational Medicine, Medical Univeristy of Lodz, Poland (https://biostat.umed.pl) 

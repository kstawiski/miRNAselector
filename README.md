![vignettes/logo.png]

# miRNAselector

![Docker](https://github.com/kstawiski/miRNAselector/workflows/Docker/badge.svg) ![R-CMD-check](https://github.com/kstawiski/miRNAselector/workflows/R-CMD-check/badge.svg) ![pkgdown](https://github.com/kstawiski/miRNAselector/workflows/pkgdown/badge.svg)

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

![](vignettes/logo.png)

# miRNAselector

![Docker](https://github.com/kstawiski/miRNAselector/workflows/Docker/badge.svg) ![R package](https://github.com/kstawiski/miRNAselector/workflows/R%20package/badge.svg)

Environment, docker-based application and R package for biomarker signiture selection from high-throughput experiments. Initially developed for miRNA-seq.

Go to https://kstawiski.github.io/miRNAselector/ for more details.

## Quick start

### Docker 


1. GPU-based, using Nvidia CUDA: [kstawiski/mirnaselector-gpu)](https://hub.docker.com/r/kstawiski/mirnaselector-gpu)

```
docker run --name mirnaselector --restart always -d -p 28888:80 --gpus all -v $(pwd)/:/miRNAselector/host/ kstawiski/mirnaselector-gpu
```

2. CPU-based: [kstawiski/mirnaselector](https://hub.docker.com/r/kstawiski/mirnaselector)

```
docker run --name mirnaselector --restart always -d -p 28888:80 -v $(pwd)/:/miRNAselector/host/ kstawiski/mirnaselector
```

As docker image updates itself, it may take few minutes for the app to be operational. You can check logs using `docker logs mirnaselector`. The GUI is accessable via `http://your-host-ip:28888/`. If you use command above, your working directory will be binded as `/miRNAselector/host/`.

3. Lite CPU-based version, used in CI and debuging, does not contain `mxnet` library: [kstawiski/mirnaselector-ci](https://hub.docker.com/r/kstawiski/mirnaselector-ci)

### R package:

We recommend installing the package in own Anaconda enviorment:

```
conda update --all 
conda install --channel "conda-forge" --channel "anaconda" --channel "r" tensorflow keras jupyter jupytext numpy pandas r r-devtools r-rgl r-rjava r-mnormt r-purrrogress r-xml gxx_linux-64 libxml2 pandoc r-rjava r-magick opencv pkgconfig gfortran_linux-64
echo "options(repos=structure(c(CRAN='http://cran.r-project.org')))" >> ~/.Rprofile
Rscript -e 'update.packages(ask = F); install.packages(c("devtools","remotes"));'
Rscript -e 'devtools::source_url("https://raw.githubusercontent.com/kstawiski/miRNAselector/master/vignettes/setup.R")'
```

You can also setup the package in your own R enviroment.

```
library("devtools") # if not installed, install via install.packages('devtools')
source_url("https://raw.githubusercontent.com/kstawiski/miRNAselector/master/vignettes/setup.R")
install_github("kstawiski/miRNAselector", force = T)
library(keras)
install_keras()
library(miRNAselector)
ks.setup()
```

## Footnote

Citation:

`In press.`

Authors:

- [Konrad Stawiski, M.D. (konrad@konsta.com.pl)](https://konsta.com.pl)
- Marcin Kaszkowiak.

For any troubleshouting use [https://github.com/kstawiski/miRNAselector/issues](https://github.com/kstawiski/miRNAselector/issues).

Department of Biostatistics and Translational Medicine, Medical Univeristy of Lodz, Poland (https://biostat.umed.pl) 

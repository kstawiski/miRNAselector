# miRNAselector - environment, docker-based application and R package for biomarker signiture selection from high-throughput experiments.

![](https://github.com/kstawiski/miRNAselector/raw/master/vignettes/logo.png)

Environment, docker-based application and R package for biomarker signiture selection from high-throughput experiments. Initially developed for miRNA-seq.

# Installation

## [OPTION 1] Docker version (recommended):

1. GPU-based, using Nvidia CUDA: [kstawiski/mirnaselector-gpu)](https://hub.docker.com/r/kstawiski/mirnaselector-gpu)

```
docker run --name mirnaselector --restart always -d -p 28888:80 --gpus all -v $(pwd)/:/miRNAselector/host/ kstawiski/mirnaselector-gpu
```

2. CPU-based: [kstawiski/mirnaselector](https://hub.docker.com/r/kstawiski/mirnaselector)

```
docker run --name mirnaselector --restart always -d -p 28888:80 -v $(pwd)/:/miRNAselector/host/ kstawiski/mirnaselector
```

As docker image updates itself, it may take few minutes for the app to be operational. You can check logs using `docker logs mirnaselector`. The GUI is accessable via `http://your-host-ip:28888/`. If you use command above, your working directory will be binded as `/miRNAselector/host/`.

3. Lite dev CPU-based version, used in CI and debuging, does not contain `mxnet` library: [kstawiski/mirnaselector-ci](https://hub.docker.com/r/kstawiski/mirnaselector-ci)

If you do not know how docker works go to [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/).

Pearls:

- Docker version contains web-based GUI allowing for easy implementation of the pipeline.
- Advanced features allow to run Jupyter-based notebooks, allowing for modification 
- Contains Jupyter-notebook-based tutorial for learning and easy implementation of R package.
- For docker-based version we assure the correct functionality. Docker container is based on configured ubuntu.

## [OPTION 2] Installation in your local R enviorment:

Use e.g. `conda create -n mirnaselector` and `conda activate mirnaselector` to set up your enviorment. 

```
conda update --all 
conda install --channel "conda-forge" --channel "anaconda" --channel "r" tensorflow keras jupyter jupytext numpy pandas r r-devtools r-rgl r-rjava r-mnormt r-purrrogress r-xml gxx_linux-64 libxml2 pandoc r-rjava r-magick opencv pkgconfig gfortran_linux-64
echo "options(repos=structure(c(CRAN='http://cran.r-project.org')))" >> ~/.Rprofile
Rscript -e 'update.packages(ask = F); install.packages(c("devtools","remotes"));'
Rscript -e 'devtools::source_url("https://raw.githubusercontent.com/kstawiski/miRNAselector/master/vignettes/setup.R")'
```

If you have compatible GPU you can consider changing `tensorflow` to `tensorflow-gpu` in `conda install` command.

2. Setup the package in your own R enviroment.

```
library("devtools") # if not installed, install via install.packages('devtools')
source_url("https://raw.githubusercontent.com/kstawiski/miRNAselector/master/vignettes/setup.R")
install_github("kstawiski/miRNAselector", force = T)
library(keras)
install_keras()
library(miRNAselector)
ks.setup()
```

Please note that application of `mxnet` requires the `mxnet` R package which is not installed automatically. You can search for `mxnet R package` in Google to find the tutorial on package installation or just use our docker container.

# Tutorials

- [Get started with basic functions of the package in local R enviorment.](articles/Tutorial.html)

Examplary files for the analysis:

- [TCGA-based tissue expression of miRNAs: `tissue_miRNA_counts.csv`](https://github.com/kstawiski/miRNAselector/blob/master/example/tissue_miRNA_counts.csv)
- [TCGA-based tissue expression of miRNAs with random missing values (for testing of missing values imputation): `tissue_miRNA_counts_withmissing.csv`](https://github.com/kstawiski/miRNAselector/blob/master/example/tissue_miRNA_counts_withmissing.csv)
- [TCGA-based tissue expression of miRNAs with random missing values (for testing of missing values imputation) and with batch variable (for testing of batch-effect correction): `tissue_miRNA_counts_withmissing_wthbatcheffect.csv`](https://github.com/kstawiski/miRNAselector/blob/master/example/tissue_miRNA_counts_withmissing_wthbatcheffect.csv)

# Development

![Docker](https://github.com/kstawiski/miRNAselector/workflows/Docker/badge.svg) ![R package](https://github.com/kstawiski/miRNAselector/workflows/R%20package/badge.svg)

- Bugs and issues: [https://github.com/kstawiski/miRNAselector/issues](https://github.com/kstawiski/miRNAselector/issues)
- Contact with developers: [Konrad Stawiski M.D. (konrad@konsta.com.pl, https://konsta.com.pl)](https://konsta.com.pl)

## Footnote

Citation:

`In press.`

Authors:

- [Konrad Stawiski, M.D. (konrad@konsta.com.pl)](https://konsta.com.pl)
- Marcin Kaszkowiak.

For any troubleshooting use [https://github.com/kstawiski/miRNAselector/issues](https://github.com/kstawiski/miRNAselector/issues).

Department of Biostatistics and Translational Medicine, Medical Univeristy of Lodz, Poland (https://biostat.umed.pl) 

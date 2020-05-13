# Environment, docker-based application and R package

`miRNAselector` package is the environment, docker-based application and R package for biomarker signiture selection from high-throughput experiments. Initially developed for miRNA-seq.

# Installation

## [OPTION 1] Docker version (recommended):

If you do not know how docker works go to [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/).

Our public docker images: 

- Docker Hub: [`kstawiski/mirnaselector`](https://hub.docker.com/r/kstawiski/mirnaselector)
- GitHub: [`docker.pkg.github.com/kstawiski/mirnaselector/app`](https://docker.pkg.github.com/kstawiski/mirnaselector/app)

Quick-start command: 

```
docker run --name mirnaselector -p 28888:80 kstawiski/mirnaselector
```

and go to [`http://127.0.0.1:28888`](http://127.0.0.1:28888) on your local machine for GUI. You can change `28888` to the port you desire.

Pearls:

- Docker version contains web-based GUI allowing for easy implementation of the pipeline.
- Advanced features allow to run Jupyter-based notebooks, allowing for modification 
- Contains Jupyter-notebook-based tutorial for learning and easy implementation of R package.
- For docker-based version we assure the correct functionality. Docker container is based on configured ubuntu.

## [OPTION 2] Installation in your local R enviorment:

Run following commands in your local R:

```
require("remotes")
install_github("kstawiski/miRNAselector", force = T)
library(miRNAselector)
```
or run `vignettes/setup.R` script to install nessesary libraries.

# Tutorials

- [Get started with basic functions of the package in local R enviorment.](https://htmlpreview.github.io/?https://github.com/kstawiski/miRNAselector/blob/master/static/Tutorial.html)

Examplary files for the analysis:

- [TCGA-based tissue expression of miRNAs: `tissue_miRNA_counts.csv`](http://kstawiski.github.io/miRNAselector/example/tissue_miRNA_counts.csv)
- [TCGA-based tissue expression of miRNAs with random missing values (for testing of missing values imputation): `tissue_miRNA_counts_withmissing.csv`](http://kstawiski.github.io/miRNAselector/example/tissue_miRNA_counts_withmissing.csv)
- [TCGA-based tissue expression of miRNAs with random missing values (for testing of missing values imputation) and with batch variable (for testing of batch-effect correction): `tissue_miRNA_counts_withmissing_wthbatcheffect.csv`](http://kstawiski.github.io/miRNAselector/example/tissue_miRNA_counts_withmissing_wthbatcheffect.csv)

# Development

 ![Docker](https://github.com/kstawiski/miRNAselector/workflows/Docker/badge.svg) ![R-CMD-check](https://github.com/kstawiski/miRNAselector/workflows/R-CMD-check/badge.svg)

- Bugs and issues: [https://github.com/kstawiski/miRNAselector/issues](https://github.com/kstawiski/miRNAselector/issues)
- Contact with developers: [Konrad Stawiski M.D. (konrad@konsta.com.pl, https://konsta.com.pl)](https://konsta.com.pl)
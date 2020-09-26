# miRNAselector - environment, docker-based application and R package for biomarker signiture selection from high-throughput experiments.

![](https://github.com/kstawiski/miRNAselector/raw/master/vignettes/logo.png)

miRNAselector is and environment, docker-based web application and R package for biomarker signiture selection (feature selection) from high-throughput experiments and other. It was initially developed for miRNA-seq (small RNA, smRNA-seq; hence the name), RNA-seq and qPCR, but can be applied for every problem where numeric features should be selected to counteract overfitting of the models. Using our tool you can for example select the miRNAs with the greatest diagnostic potential (based on the results of miRNA-seq, for validation in qPCR experiments).

The main purpose of miRNAselector is to provide you with the set of **candidate features (biomarkers) for further validation of biomarker study** from e.g. high-throughput experiments. The package performs feature selection first. In the next step the sets of features are tested in the process called "benchmarking". In benchmarking **we test all of those sets of features (biomarkers) using various data-mining (machine learning) methods**. Based on the avarage performance of sets in cross-validation or holdout-validation (testing on test set and/or validation set) we can sugesst which of the signitures (set of features) is have the greatest potential in further validation.

## Public implementation

For testing purposes, we offer a publically available version of our software at [https://biostat.umed.pl/miRNAselector/](https://biostat.umed.pl/miRNAselector/). Please note, however, that we restrict this instance to 12 CPU cores and 16 GB of RAM; thus, more advanced and complex analyses may take a significant amount of time or throw an out-of-the-memory error. Moreover, we cannot guarantee the safe storage of uploaded data. The great potential for customization and extension of the environment comes with some security flaws (e.g. access to files via shell or Jupyter), so we highly discourage the users from using this instance for real-life projects.
Please also note that the public docker container restarts itself once a week. Project files should be intact, but we may occasionally remove some old projects to save space in our server workspace.

## Installation

### [OPTION 1] Docker version (recommended):

Tailor the docker container image for your enviorment:

1. GPU-based, using Nvidia CUDA: [kstawiski/mirnaselector-gpu)](https://hub.docker.com/r/kstawiski/mirnaselector-gpu)

```
docker run --name mirnaselector --restart always -d -p 28888:80 --gpus all -v $(pwd)/:/miRNAselector/host/ kstawiski/mirnaselector-gpu
```

2. CPU-based: [kstawiski/mirnaselector](https://hub.docker.com/r/kstawiski/mirnaselector)

```
docker run --name mirnaselector --restart always -d -p 28888:80 -v $(pwd)/:/miRNAselector/host/ kstawiski/mirnaselector
```

As docker image updates itself, it may take few minutes for the app to be operational. You can check logs using `docker logs mirnaselector`. The GUI (web-based user interface) is accessable via `http://your-host-ip:28888/`. If you use command above, your working directory will be binded as `/miRNAselector/host/`.

3. Lite dev CPU-based version, used in CI and debuging, does not contain `mxnet` library: [kstawiski/mirnaselector-ci](https://hub.docker.com/r/kstawiski/mirnaselector-ci)

If you do not know how docker works go to [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/).

Pearls:

- Docker version contains web-based GUI allowing for easy implementation of the pipeline.
- Advanced features allow to run Jupyter-based notebooks, allowing for modification 
- Contains Jupyter-notebook-based tutorial for learning and easy implementation of R package.
- For docker-based version we assure the correct functionality. Docker container is based on configured ubuntu.

### [OPTION 2] Installation in your local R enviorment:

There are 2 ways for installing miRNAselector without using docker. Please note however that the **web-based GUI (used interface) is available only in docker version**.

**1. Use anaconda.** (recommended)

Use e.g. `conda create -n mirnaselector` and `conda activate mirnaselector` to set up your enviorment. 

```
conda update --all 
conda install --channel "conda-forge" --channel "anaconda" --channel "r" tensorflow keras jupyter jupytext numpy pandas r r-devtools r-rgl r-rjava r-mnormt r-purrrogress r-xml gxx_linux-64 libxml2 pandoc r-rjava r-magick opencv pkgconfig gfortran_linux-64
echo "options(repos=structure(c(CRAN='http://cran.r-project.org')))" >> ~/.Rprofile
Rscript -e 'update.packages(ask = F); install.packages(c("devtools","remotes"));'
Rscript -e 'devtools::source_url("https://raw.githubusercontent.com/kstawiski/miRNAselector/master/vignettes/setup.R")'
```

If you have compatible GPU you can consider changing `tensorflow` to `tensorflow-gpu` in `conda install` command.

**2. Setup the package in your own R enviroment.**

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

## Tutorials

- [Get started with basic functions of the package in local R enviorment.](articles/Tutorial.html)

Examplary files for the analysis:

- [TCGA-based tissue expression of miRNAs: `tissue_miRNA_counts.csv`](https://github.com/kstawiski/miRNAselector/blob/master/example/tissue_miRNA_counts.csv)
- [TCGA-based tissue expression of miRNAs with random missing values (for testing of missing values imputation): `tissue_miRNA_counts_withmissing.csv`](https://github.com/kstawiski/miRNAselector/blob/master/example/tissue_miRNA_counts_withmissing.csv)
- [TCGA-based tissue expression of miRNAs with random missing values (for testing of missing values imputation) and with batch variable (for testing of batch-effect correction): `tissue_miRNA_counts_withmissing_wthbatcheffect.csv`](https://github.com/kstawiski/miRNAselector/blob/master/example/tissue_miRNA_counts_withmissing_wthbatcheffect.csv)

## Development

![Docker](https://github.com/kstawiski/miRNAselector/workflows/Docker/badge.svg)     ![R package](https://github.com/kstawiski/miRNAselector/workflows/R%20package/badge.svg)

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

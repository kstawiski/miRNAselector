.onAttach <- function(libname, pkgname) {
  options(rgl.useNULL = TRUE)
  suppressWarnings(suppressMessages(require("curl", character.only = TRUE)))
  suppressWarnings(suppressMessages(require("devtools", character.only = TRUE)))
  suppressWarnings(suppressMessages(require("utils", character.only = TRUE)))
  if(curl::has_internet()) {
    source_url("https://raw.githubusercontent.com/kstawiski/miRNAselector/master/vignettes/setup.R")
  }
  # tylko_cran = c("BiocManager","devtools","reticulate","remotes")
  # if (length(setdiff(tylko_cran, rownames(installed.packages()))) > 0) {
  # install.packages(setdiff(tylko_cran, rownames(installed.packages())), ask = F)  }
  #
  # packages = c("remotes","devtools","rlang","ps","roxygen2", "plotly", "rJava", "mice","BiocManager", "MatchIt","curl",
  #                      "reticulate", "kableExtra","plyr","dplyr","edgeR","epiDisplay","rsq","MASS","Biocomb","caret","dplyr",
  #                      "pROC","ggplot2","DMwR", "doParallel", "Boruta", "spFSR", "varSelRF", "stringr", "psych", "C50", "randomForest", "doSNOW",
  #                      "foreach","data.table", "ROSE", "deepnet", "gridExtra", "stargazer","gplots","My.stepwise","snow", "sva", "Biobase",
  #                      "calibrate", "ggrepel", "networkD3", "VennDiagram","RSNNS", "kernlab", "car", "PairedData",
  #                      "profileR","classInt","kernlab","xgboost", "keras", "tidyverse", "cutpointr","tibble","tidyr",
  #                      "rpart", "party", "mgcv", "GDCRNATools", "rJava",
  #                      "imputeMissings", "visdat", "naniar", "stringr", "doSNOW", "R.utils", "TCGAbiolinks", "GDCRNATools",
  #                      "kableExtra", "VIM", "mice", "MatchIt", "XML", "rmarkdown", "xtable", "ComplexHeatmap","circlize",
  #                      "BiocStyle","magick", "BiocCheck")
  #
  # if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  # BiocManager::install(setdiff(packages, rownames(installed.packages())), ask = F)  }
  #
  # # Paczki z githuba
  # if("bounceR" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("STATWORX/bounceR") }
  # if("cutpointr" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("Thie1e/cutpointr") }
  # if("ggbiplot" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("vqv/ggbiplot") }


  packageStartupMessage("\n\nWelcome to miRNAselector!\nAuthors: Konrad Stawiski M.D. (konrad@konsta.com.pl) and Marcin Kaszkowiak.\nFor more details go to https://kstawiski.github.io/miRNAselector/\n")
}

.onLoad <- function(libname, pkgname) {

}

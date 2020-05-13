.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Welcome to miRNAselector!\n\nAuthors: Konrad Stawiski M.D. (konrad@konsta.com.pl) and Marcin Kaszkowiak.\n\nFor more details go to https://kstawiski.github.io/miRNAselector/")
}

.onLoad <- function(libname, pkgname) {
  suppressWarnings(suppressMessages(require("BiocManager", character.only = TRUE)))
  
  # Normalne paczki
  packages <- c("remotes","plyr","dplyr","edgeR","epiDisplay","rsq","MASS","Biocomb","caret","dplyr", "roxygen2", "plotly", "rJava", "mice", "MatchIt", "kableExtra", "reticulate",
                       "pROC","ggplot2","DMwR", "doParallel", "Boruta", "spFSR", "varSelRF", "stringr", "psych", "C50", "randomForest",
                       "foreach","data.table", "ROSE", "deepnet", "gridExtra", "stargazer","gplots","My.stepwise","snow", "sva", "Biobase",
                       "calibrate", "ggrepel", "networkD3", "VennDiagram","RSNNS", "kernlab", "car", "PairedData",
                       "profileR","classInt","kernlab","xgboost", "keras", "tidyverse", "tibble","tidyr", "rpart", "party", "mgcv", "GDCRNATools",
                       "imputeMissings", "visdat", "naniar", "stringr", "doSNOW", "R.utils", "TCGAbiolinks", "GDCRNATools", "kableExtra", "VIM", "mice", "MatchIt", "XML", "rmarkdown", "xtable", "ComplexHeatmap","circlize")
  if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  BiocManager::install(setdiff(packages, rownames(installed.packages())), ask = F)  }

  # Paczki z githuba
  if("bounceR" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("STATWORX/bounceR") }
  if("cutpointr" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("Thie1e/cutpointr") }
  if("ggbiplot" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("vqv/ggbiplot") }

  # Keras
  suppressWarnings(suppressMessages(require("keras", character.only = TRUE)))
  if (!is_keras_available()) { install_keras() }

  invisible(rownames(installed.packages()))
  }

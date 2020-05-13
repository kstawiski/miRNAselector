install.packages("devtools",repos = "http://cran.r-project.org")
install.packages(c("rlang","ps"), type = "source")
install.packages(c("roxygen2", "plotly", "rJava", "mice", "MatchIt", "kableExtra"))
install.packages("BiocManager",repos = "http://cran.r-project.org")
install.packages("plotly")
install.packages("reticulate")
library(BiocManager)
BiocManager::install(c("devtools","plyr","dplyr","edgeR","epiDisplay","rsq","MASS","Biocomb","caret","dplyr",
                       "pROC","ggplot2","DMwR", "doParallel", "Boruta", "spFSR", "varSelRF", "stringr", "psych", "C50", "randomForest",
                       "foreach","data.table", "ROSE", "deepnet", "gridExtra", "stargazer","gplots","My.stepwise","snow", "sva", "Biobase",
                       "calibrate", "ggrepel", "networkD3", "VennDiagram","RSNNS", "kernlab", "car", "PairedData",
                       "profileR","classInt","kernlab","xgboost", "keras", "tidyverse", "cutpointr","tibble","tidyr", "rpart", "party", "mgcv", "GDCRNATools",
                       "imputeMissings", "visdat", "naniar", "stringr", "doSNOW", "R.utils", "TCGAbiolinks", "GDCRNATools", "kableExtra", "VIM", "mice", "MatchIt", "XML", "rmarkdown", "xtable", "ComplexHeatmap","circlize"))
devtools::install_github("STATWORX/bounceR", force = T)
#devtools::install_github("rstudio/reticulate")
devtools::install_github("Thie1e/cutpointr", force = T)
devtools::install_github("vqv/ggbiplot", force = T)
library(keras)
install_keras()


#devtools::install_github("kstawiski/miRNAselector", force = T) # Install our package.

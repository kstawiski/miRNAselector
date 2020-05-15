#install.packages("remotes",repos = "http://cran.r-project.org")
#install.packages("roxygen2")
#install.packages("BiocManager",repos = "http://cran.r-project.org")
#suppressMessages(library(BiocManager))
#BiocManager::install(c("reticulate","remotes","plyr","dplyr","edgeR","epiDisplay","rsq","MASS","Biocomb","caret","dplyr",
#                       "pROC","ggplot2","DMwR", "doParallel", "Boruta", "spFSR", "varSelRF", "stringr", "psych", "C50", "randomForest",
#                       "foreach","data.table", "ROSE", "deepnet", "gridExtra", "stargazer","gplots","My.stepwise","snow",
#                       "calibrate", "ggrepel", "networkD3", "VennDiagram","RSNNS", "kernlab", "car", "PairedData",
#                       "profileR","classInt","kernlab","xgboost", "keras", "tidyverse", "cutpointr","tibble","tidyr", "rpart", "party", "mgcv", "GDCRNATools",
#                       "imputeMissings", "visdat", "naniar", "stringr", "doSNOW", "R.utils"))
#remotes::install_github("STATWORX/bounceR", force = T)
#remotes::install_github("rstudio/reticulate")
#remotes::install_github("vqv/ggbiplot", force = T)
#suppressMessages(library(keras))
#install_keras()

#system("cd /miRNAselector/miRNAselector && git reset --hard && git clean -df && git pull")
library(remotes)
install_github("kstawiski/miRNAselector") # Install our package.

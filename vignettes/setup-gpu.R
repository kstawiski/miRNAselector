gpu = T # do you have GPU with CUDA?
install.packages("devtools")
install.packages("BiocManager",repos = "http://cran.r-project.org")
library(BiocManager)
BiocManager::install(c("reticulate","devtools","plyr","dplyr","edgeR","epiDisplay","rsq","MASS","Biocomb","caret","dplyr",
                       "pROC","ggplot2","DMwR", "doParallel", "Boruta", "spFSR", "varSelRF", "stringr", "psych", "C50", "randomForest",
                       "foreach","data.table", "ROSE", "deepnet", "gridExtra", "stargazer","gplots","My.stepwise","snow",
                       "calibrate", "ggrepel", "networkD3", "VennDiagram","RSNNS", "kernlab", "car", "PairedData",
                       "profileR","classInt","kernlab","xgboost", "keras", "tidyverse", "cutpointr","tibble","tidyr", "rpart", "party", "mgcv", "GDCRNATools",
                       "imputeMissings", "visdat", "naniar", "stringr", "doSNOW", "R.utils"))
devtools::install_github("STATWORX/bounceR", force = T)
#devtools::install_github("rstudio/reticulate")
devtools::install_github("vqv/ggbiplot")
library(keras)
install_keras(tensorflow = "gpu")




devtools::install_github("kstawiski/miRNAselector") # Install our package.

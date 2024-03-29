## Default repo
# Ubuntu: apt install default-jre default-jdk libmagick++-dev zlib1g-dev libglu1-mesa-dev freeglut3-dev mesa-common-dev r-cran-rgl
r = getOption("repos")
r["CRAN"] = "https://cran.r-project.org"
options(repos = r)


tylko_cran = c("BiocManager","devtools","reticulate","remotes","keras")
if (length(setdiff(tylko_cran, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(tylko_cran, rownames(installed.packages())), ask = F)  }

packages = c("remotes","devtools","parallel","rlang","ps","roxygen2", "plotly", "rJava", "mice","BiocManager", "MatchIt","curl",
                       "reticulate", "kableExtra","plyr","dplyr","edgeR","epiDisplay","rsq","MASS","Biocomb","caret","dplyr",
                       "pROC","ggplot2","DMwR", "doParallel", "Boruta", "spFSR", "varSelRF", "stringr", "psych", "C50", "randomForest", "doParallel",
                       "foreach","data.table", "ROSE", "deepnet", "gridExtra", "stargazer","gplots","My.stepwise","snow", "sva", "Biobase",
                       "calibrate", "ggrepel", "networkD3", "VennDiagram","RSNNS", "kernlab", "car", "PairedData",
                       "profileR","classInt","kernlab","xgboost", "keras", "tidyverse", "cutpointr","tibble","tidyr",
                       "rpart", "party", "mgcv", "GDCRNATools", "rJava", "cutpointr", "HTqPCR", "nondetects",
                       "imputeMissings", "visdat", "naniar", "stringr", "R.utils", "TCGAbiolinks", "GDCRNATools",
                       "kableExtra", "VIM", "mice", "MatchIt", "XML", "rmarkdown", "xtable", "ComplexHeatmap","circlize",
                       "BiocStyle","magick", "BiocCheck","cluster","tidyselect","ellipsis","funModeling", "mnormt","xlsx","klaR")

if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  BiocManager::install(setdiff(packages, rownames(installed.packages())), ask = F)  }

library(devtools)
library(remotes)
# Paczki z githuba
if("bounceR" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("STATWORX/bounceR") }
if("ggbiplot" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("vqv/ggbiplot") }
if("mnormt" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("cran/mnormt") }
if("purrrogress" %in% rownames(installed.packages()) == FALSE) {  remotes::install_github("halpo/purrrogress") } 
if("feseR" %in% rownames(installed.packages()) == FALSE) { install_github("enriquea/feseR") }


# tryCatch(
#         {
#             if(grepl("64", Sys.info()[["machine"]], fixed = TRUE)) {
#             # Keras
#             library(keras)
#             if(!keras::is_keras_available()) {

#               install_keras() }
#             } else { message("\n\n!!!!! If you are not running 64-bit based machine you might experience problems with keras and tensorflow that are unrelated to this package. !!!!!\n\n") }

#         },
#         error=function(cond) {
#             message(cond)
#             message("Unable to verify the correctness of keras installation. Please run keras::install_keras() later.")
#         },
#         warning=function(cond) {
#             message(cond)
#             message("Unable to verify the correctness of keras installation. Please run keras::install_keras() later.")
#         },
#         finally={

#         }
#     )

if(grepl("64", Sys.info()[["machine"]], fixed = TRUE) && !keras::is_keras_available()) { message("Keras is not installed. Please run keras::install_keras() later.") }

# miRNAselector
if("miRNAselector" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("kstawiski/miRNAselector", upgrade = "never") }
message("OK! miRNAselector is installed correctly!")

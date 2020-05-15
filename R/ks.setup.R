#' ks.setup
#' 
#' Run this function to be sure that everything is installed properly for miRNAselector.
#' 
ks.setup = function(keras = TRUE, msg = TRUE) {
    suppressWarnings(suppressMessages(require("curl", character.only = TRUE)))
    suppressWarnings(suppressMessages(require("devtools", character.only = TRUE)))
    suppressWarnings(suppressMessages(require("utils", character.only = TRUE)))
    

    tylko_cran = c("BiocManager","devtools","reticulate","remotes")
    if (length(setdiff(tylko_cran, rownames(installed.packages()))) > 0) {
    install.packages(setdiff(tylko_cran, rownames(installed.packages())), ask = F)  }

    packages = c("remotes","devtools","rlang","ps","roxygen2", "plotly", "rJava", "mice","BiocManager", "MatchIt","curl",
                        "reticulate", "kableExtra","plyr","dplyr","edgeR","epiDisplay","rsq","MASS","Biocomb","caret","dplyr",
                        "pROC","ggplot2","DMwR", "doParallel", "Boruta", "spFSR", "varSelRF", "stringr", "psych", "C50", "randomForest", "doSNOW",
                        "foreach","data.table", "ROSE", "deepnet", "gridExtra", "stargazer","gplots","My.stepwise","snow", "sva", "Biobase",
                        "calibrate", "ggrepel", "networkD3", "VennDiagram","RSNNS", "kernlab", "car", "PairedData",
                        "profileR","classInt","kernlab","xgboost", "keras", "tidyverse", "cutpointr","tibble","tidyr",
                        "rpart", "party", "mgcv", "GDCRNATools", "rJava",
                        "imputeMissings", "visdat", "naniar", "stringr", "doSNOW", "R.utils", "TCGAbiolinks", "GDCRNATools",
                        "kableExtra", "VIM", "mice", "MatchIt", "XML", "rmarkdown", "xtable", "ComplexHeatmap","circlize",
                        "BiocStyle","magick", "BiocCheck","cluster")

    if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
    BiocManager::install(setdiff(packages, rownames(installed.packages())), ask = F)  }

    # Paczki z githuba
    if("bounceR" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("STATWORX/bounceR") }
    if("cutpointr" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("Thie1e/cutpointr") }
    if("ggbiplot" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("vqv/ggbiplot") }

    if(keras == TRUE) {

                if(grepl("64", Sys.info()[["machine"]], fixed = TRUE)) {
                # Keras
                suppressWarnings(suppressMessages(require("keras", character.only = TRUE)))
                if(!is_keras_available()) { install_keras() }
                } else { message("\n\n!!!!! If you are not running 64-bit based machine you might experience problems with keras and tensorflow that are unrelated to this package. !!!!!\n\n") }

            }

    # miRNAselector
    if("miRNAselector" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("kstawiski/miRNAselector") }
    if (msg) { message("OK! miRNAselector is installed correctly!") }

}
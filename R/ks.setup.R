#' ks.setup
#'
#' Run this function to be sure that everything is installed properly for miRNAselector.
#'
#' @param keras Try to install keras using install_keras()?
#' @param msg Display OK message at the end?
#'
#' @export
#'
ks.setup = function(keras = TRUE, msg = TRUE) {
    suppressWarnings(suppressMessages(require("curl", character.only = TRUE)))
    suppressWarnings(suppressMessages(require("devtools", character.only = TRUE)))
    suppressWarnings(suppressMessages(require("utils", character.only = TRUE)))


    tylko_cran = c("BiocManager","devtools","reticulate","remotes","keras")
    if (length(setdiff(tylko_cran, rownames(installed.packages()))) > 0) {
    install.packages(setdiff(tylko_cran, rownames(installed.packages())), ask = F)  }

    packages = c("remotes","devtools","parallel","rlang","ps","roxygen2", "plotly", "rJava", "mice","BiocManager", "MatchIt","curl",
                        "reticulate", "kableExtra","plyr","dplyr","edgeR","epiDisplay","rsq","MASS","Biocomb","caret","dplyr",
                        "pROC","ggplot2","DMwR", "doParallel", "Boruta", "spFSR", "varSelRF", "stringr", "psych", "C50", "randomForest",
                        "foreach","data.table", "ROSE", "deepnet", "gridExtra", "stargazer","gplots","My.stepwise", "sva", "Biobase",
                        "calibrate", "ggrepel", "networkD3", "VennDiagram","RSNNS", "kernlab", "car", "PairedData",
                        "profileR","classInt","kernlab","xgboost", "keras", "tidyverse", "cutpointr","tibble","tidyr",
                        "rpart", "party", "mgcv", "GDCRNATools", "rJava",
                        "imputeMissings", "visdat", "naniar", "stringr", "R.utils", "TCGAbiolinks", "GDCRNATools",
                        "kableExtra", "VIM", "mice", "MatchIt", "XML", "rmarkdown", "xtable", "ComplexHeatmap","circlize",
                        "BiocStyle","magick", "BiocCheck","cluster","tidyselect","ellipsis","klaR")

    if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
    BiocManager::install(setdiff(packages, rownames(installed.packages())), ask = F)  }

    suppressMessages(library(devtools))
    suppressMessages(library(remotes))

# Paczki z githuba
if("bounceR" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("STATWORX/bounceR") }
if("ggbiplot" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("vqv/ggbiplot") }
if("mnormt" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("cran/mnormt") }
if("purrrogress" %in% rownames(installed.packages()) == FALSE) {  remotes::install_github("halpo/purrrogress") } 
if("feseR" %in% rownames(installed.packages()) == FALSE) { install_github("enriquea/feseR") }

    if(keras == TRUE) {

                if(grepl("64", Sys.info()[["machine"]], fixed = TRUE)) {
                # Keras
                library(keras)
                if(!is_keras_available()) { message("Keras is not avaible. Please run keras::install_keras() to install it!") }
                } else { message("\n\n!!!!! If you are not running 64-bit based machine you might experience problems with keras and tensorflow that are unrelated to this package. !!!!!\n\n") }

    }

    # miRNAselector
    if("miRNAselector" %in% rownames(installed.packages()) == FALSE) { remotes::install_github("kstawiski/miRNAselector") }
    if (msg) { message("OK! miRNAselector is installed correctly!") }

}

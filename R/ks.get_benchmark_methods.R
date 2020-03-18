#' ks.get_benchmark_methods
#'
#' Get methods checked in benchmark.
#'
#' @param benchmark_csv Path to benchmark csv file.
#' @return Vector of feature selection methods checked.
ks.get_benchmark_methods = function(benchmark_csv = "benchmark1578929876.21765.csv"){
  library(limma)
  library(plyr)
  library(dplyr)
  library(edgeR)
  library(epiDisplay)
  library(rsq)
  library(MASS)
  library(Biocomb)
  library(caret)
  library(dplyr)
  library(epiDisplay)
  library(pROC)
  library(ggplot2)
  library(DMwR)
  library(ROSE)
  library(gridExtra)
  library(gplots)
  library(devtools)
  library(stringr)
  library(data.table)
  library(tidyverse)
  benchmark = read.csv(benchmark_csv, stringsAsFactors = F)
  rownames(benchmark) = make.names(benchmark$method, unique = T)
  benchmark$method = rownames(benchmark)
  temp = dplyr::select(benchmark, ends_with("_valid_Accuracy"))
  metody = strsplit2(colnames(temp), "_")[,1]
  return(metody)
}

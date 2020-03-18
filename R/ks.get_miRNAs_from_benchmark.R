#' ks.get_miRNAs_from_benchmark
#'
#' Get which miRNAs are used by which method in the benchmark.
#'
#' @param benchmark_csv Path to benchmark csv.
#' @param method Method of interest.
#'
#' @return Vector of miRNAs.
ks.get_miRNAs_from_benchmark = function(benchmark_csv = "benchmark1578990441.6531.csv", method = "fcsig")
{
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
  return(all.vars(as.formula(benchmark$miRy[which(rownames(benchmark) == method)]))[-1])
}

#' ks.best_signiture_proposals
#'
#' Propose the best signture based on benchamrk methods.
#' This function calculated the `metaIndex1` value which is the mean accuracy from train, test and validation dataset.
#' In the next step, it sorts the miRNA sets based on `metaIndex1` score. The first row in resulting data frame is the winner miRNA set.
#'
#'  @param benchmark_csv Path to benchmark csv.
#'  @param without_train One can argue, that accuracy on training dataset should not be used in calculation of metaIndex. By setting this to TRUE, you can calculate it without train dataset.
#'
#'  @return The benchmark sorted by metaIndex. First row is the best performing miRNA set.
ks.best_signiture_proposals = function(benchmark_csv = "benchmark1578929876.21765.csv", without_train = F){
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
  acc = dplyr::select(benchmark, ends_with("_train_Accuracy"), ends_with("_test_Accuracy"),ends_with("_valid_Accuracy") )
  if (without_train == T) { acc = dplyr::select(benchmark, ends_with("_test_Accuracy"),ends_with("_valid_Accuracy")) }
  acc$metaindex = rowMeans(acc)
  acc$method = rownames(benchmark)
  acc$miRy = benchmark$miRy
  rownames(acc) = make.names(benchmark$method, unique = T)
  acc = acc %>% arrange(desc(metaindex))
  return(acc)
}

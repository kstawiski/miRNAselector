#' ks.prepare_split
#'
#' Create split required for `ks.miRNAselector()` and all the following functions. It is obligatory to use it.
#' The function devides the dataset into training, testing and validation set. Be default (as `train_proc=0.6`) 60 perc. of cases will be assigned to trainining datset.
#' The rest is devided into testing and validation dataset in half, ending in 60 perc. of cases in training dataset, 20 perc. of cases in testing dataset and 20 perc. of cases in validation dataset.
#' Metadata have to have `Class` variable, with `Cancer` and `Control` values.
#'
#' @param metadane Metadata of cases. Must contain `Class` variable with `Cancer` and `Control` values.
#' @param ttpm Normalized counts used (primary data for the rest of the analysis).
#' @param train_proc What perc. should be kept in training dataset?
#'
#' @return The mixed dataset is return. In working directory mixed_train.csv, mixed_test.csv and mixed_valid.csv are saved. This is a crucial step in data preprocessing.
ks.prepare_split = function(metadane = metadane, ttpm = ttpm_pofiltrze, train_proc = 0.6)
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
  tempp = cbind(metadane, ttpm)
  # Podzial - http://topepo.github.io/caret/data-splitting.html#simple-splitting-based-on-the-outcome
  set.seed(1)
  mix = rep("unasign", nrow(tempp))
  library(caret)
  train.index <- createDataPartition(tempp$Class, p = train_proc, list = FALSE)
  mix[train.index] = "train"
  train = tempp[train.index,]


  tempp2 =  tempp[-train.index,]
  train.index <- createDataPartition(tempp2$Class, p = .5, list = FALSE)
  test = tempp2[train.index,]
  valid = tempp2[-train.index,]
  write.csv(train, "mixed_train.csv",row.names = F)
  write.csv(test, "mixed_test.csv",row.names = F)
  write.csv(valid, "mixed_valid.csv",row.names = F)

  train$mix = "train"
  test$mix = "test"
  valid$mix = "valid"

  mixed = rbind(train,test,valid)

  metadane2 = dplyr::select(mixed, -starts_with("hsa"))
  ttpm2 = dplyr::select(mixed, starts_with("hsa"))

  mixed2 = cbind(metadane2, ttpm2)
  write.csv(mixed2, "mixed.csv",row.names = F)
  cat("\nSaved 3 sets as csv in working directory. Retruned mixed dataset.")
  return(mixed)
}

#' ks.miRNA_signiture_overlap
#'
#' A function to generate venn diagram and check the overlap between formulas.
#'
#' @param which_formulas Which formulas to check?
#' @param benchmark_csv Which benchmark to use?
#'
#' @return Object of `venn()` function which can be used for plotting venn diagram and check the overlap.
ks.miRNA_signiture_overlap = function(which_formulas = c("sig","cfs"), benchmark_csv = "benchmark1578929876.21765.csv")
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
  wybrane = list()
  for (i in 1:length(which_formulas)) {
    ktora_to = match(which_formulas[i], rownames(benchmark))
    temp = as.formula(benchmark$miRy[ktora_to])
    wybrane[[rownames(benchmark)[ktora_to]]] = all.vars(temp)[-1]
  }
  require("gplots")
  temp = venn(wybrane)
  temp
}

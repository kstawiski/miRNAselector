#' ks.PCA
#'
#' Conduct PCA and create biplot.
#'
#' @param ttpm_pofiltrze Normalizaed counts in `ttpm` format.
#' @param meta Factor of cases labels that should be visualized on biplot.
#'
#' @return Biplot.
ks.PCA = function(ttpm_pofiltrze, meta) {
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
  dane.pca <- prcomp(ttpm_pofiltrze, scale. = TRUE)
  library(ggbiplot)
  ggbiplot(dane.pca,var.axes = FALSE,ellipse=TRUE,circle=TRUE, groups=as.factor(meta))
}

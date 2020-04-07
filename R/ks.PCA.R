#' ks.PCA
#'
#' Conduct PCA and create biplot.
#'
#' @param ttpm_pofiltrze Normalizaed counts in `ttpm` format.
#' @param meta Factor of cases labels that should be visualized on biplot.
#'
#' @return Biplot.
ks.PCA = function(ttpm_pofiltrze, meta) {
  suppressMessages(library(plyr))
  suppressMessages(library(dplyr))
  suppressMessages(library(edgeR))
  suppressMessages(library(epiDisplay))
  suppressMessages(library(rsq))
  suppressMessages(library(MASS))
  suppressMessages(library(Biocomb))
  suppressMessages(library(caret))
  suppressMessages(library(dplyr))
  suppressMessages(library(epiDisplay))
  suppressMessages(library(pROC))
  suppressMessages(library(ggplot2))
  suppressMessages(library(DMwR))
  suppressMessages(library(ROSE))
  suppressMessages(library(gridExtra))
  suppressMessages(library(gplots))
  suppressMessages(library(devtools))
  suppressMessages(library(stringr))
  suppressMessages(library(data.table))
  suppressMessages(library(tidyverse))
  
  
  for(i in colnames(ttpm_pofiltrze)) {
    if(!is.numeric(ttpm_pofiltrze[, i])) {
      stop("Please provide a dataframe with only numeric variables")
    }
  }
  
  if(is.data.frame(meta)) {
    stop("Please provide a single categorical vector")
  }
  
  dane.pca <- prcomp(ttpm_pofiltrze, scale. = TRUE)
  suppressMessages(library(ggbiplot))
  ggbiplot(dane.pca,var.axes = FALSE,ellipse=TRUE,circle=TRUE, groups=as.factor(meta))
}

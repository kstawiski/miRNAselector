#' ks.PCA_3D
#'
#' Conduct PCA and create 3D scatterplot form first 3 components.
#'
#' @param ttpm_pofiltrze Normalizaed counts in `ttpm` format.
#' @param meta Factor of cases labels that should be visualized on biplot.
#'
#' @return Plotly 3D object.
ks.PCA_3D = function(ttpm_pofiltrze, meta) {
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
  library(plotly)
  pc = as.data.frame(dane.pca$x)
  pc = cbind(pc, meta)

  p <- plot_ly(data = pc, x = ~PC1, y = ~PC2, z = ~PC3, color = ~meta) %>%
    add_markers() %>%
    layout(scene = list(xaxis = list(title = 'PC1'),
                        yaxis = list(title = 'PC2'),
                        zaxis = list(title = 'PC3')))

  p
}

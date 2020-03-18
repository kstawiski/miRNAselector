#' ks.heatmap
#'
#' Draw a heatmap of selected miRNAs.
#'
#' @param x Matrix of log-transformed TPM-normalized counts with miRNAs in columns and cases in rows.
#' @param rlab Data frame of factors to be marked on heatmap (like batch or class). Maximum of 2 levels for every variable is supported.
#' @param zscore Whether to z-score values before clustering and plotting.
#'
#' @return Heatmap.
ks.heatmap = function(x = trainx[,1:10], rlab = data.frame(Batch = dane$Batch, Class = dane$Class), zscore = F, margins = c(10,10)) {
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
  assigcolor = character()
  assigcode = character()
  kolory = rep(palette(),20)[-1]
  kolor_i = 1
  for (i in 1:ncol(rlab)){
    o_ile = as.numeric(length(unique(rlab[,i])))
    assigcode = c(assigcode, as.character(unique(rlab[,i])))
    assigcolor = c(assigcolor, kolory[kolor_i:(kolor_i+o_ile-1)])
    #levels(rlab[,i]) = topo.colors(length(unique(rlab[,i])))
    levels(rlab[,i]) = kolory[kolor_i:(kolor_i+o_ile-1)]
    kolor_i = kolor_i+o_ile
  }
  assig = data.frame(assigcode, assigcolor)
  #levels(rlab$Batch) = rainbow(length(unique(dane$Batch)))
  #levels(rlab$Class) = c("red","green") # red - cancer, green - control
  x2 = as.matrix(x)
  colnames(x2) = gsub("\\.","-", colnames(x2))

  if(zscore == F) {
    brks<-ks.diverge_color(x2, centeredOn = median(x2))

    # colors = seq(min(x2), max(x2), by = 0.01)
    # my_palette <- colorRampPalette(c("blue", "white", "red"))(n = length(colors) - 1)

    rlab = as.matrix(rlab)
    ks.heatmap.3(x2, hclustfun=ks.myclust, distfun=ks.mydist,
                 RowSideColors=t(rlab),
                 margins = margins,
                 KeyValueName="log10(TPM)",
                 symm=F,symkey=F,symbreaks=T, scale="none",
                 col=as.character(brks[[2]]),
                 breaks=as.numeric(brks[[1]]$brks),
                 #legend = T
                 #,scale="column"
    )
    legend("topright",
           assigcode, fill=assigcolor, horiz=F, bg="transparent", cex=0.5)
  } else {
    x3 = x2
    for(i in 1:ncol(x2)) {
      x3[,i] = scale(x2[,i])
    }

    brks<-ks.diverge_color(x3, centeredOn = median(0))

    # colors = seq(min(x2), max(x2), by = 0.01)
    # my_palette <- colorRampPalette(c("blue", "white", "red"))(n = length(colors) - 1)

    rlab = as.matrix(rlab)
    ks.heatmap.3(x3, hclustfun=ks.myclust, distfun=ks.mydist,
                 RowSideColors=t(rlab),
                 margins = margins,
                 KeyValueName="Z-score log10(TPM)",
                 symm=F,symkey=F,symbreaks=T, scale="none",
                 col=as.character(brks[[2]]),
                 breaks=as.numeric(brks[[1]]$brks),
                 #legend = T
                 #,scale="column"
    )
    legend("topright",
           assigcode, fill=assigcolor, horiz=F, bg="transparent", cex=0.5)
  }
}

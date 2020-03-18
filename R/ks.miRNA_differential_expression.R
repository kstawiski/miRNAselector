#' ks.miRNA_differential_expression
#'
#' The variable performes standard differential expression analysis using unpaired t-test with BH and Bonferonni correction.
#' It requires `ttpm_pofiltrze` object, which is a matrix of log-transformed TPM-normalized miRNAs counts with miRNAs placed in `ttpm` design (i.e. columns and cases placed as rows).
#' Classess should be passed as `klasy` and this should be a vector of length equal to number of rows in `ttpm_polfiltrze` and contain only "Cancer" or "Control" labels!!
#' The function returns the miRNAs sorted by BH-corrected p-value.
#'
#' @param ttpm_pofiltrze matrix of log-transformed TPM-normalized miRNAs counts with miRNAs placed in `ttpm` design (i.e. columns and cases placed as rows)
#' @param klasy vector describing label for each case. It should contain only "Cancer" and "Control" labeles!!!!
#'
#' @return Data frame with results.
ks.miRNA_differential_expression = function(ttpm_pofiltrze, klasy)
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
  wyniki = data.frame(miR = as.character(colnames(ttpm_pofiltrze)))

  library(dplyr)

  for (i in 1:length(colnames(ttpm_pofiltrze)))
  {
    # Filtry
    #wyniki[i,"jakieszero"] = ifelse(sum(ttpm_pofiltrze[,i] == 0) > 0, "tak", "nie")

    # Średnia i SD
    wyniki[i,"mean logtpm"] = mean(ttpm_pofiltrze[,i])
    wyniki[i,"median logtpm"] = median(ttpm_pofiltrze[,i])
    wyniki[i,"SD logtpm"] = sd(ttpm_pofiltrze[,i])

    # Cancer
    tempx = ttpm_pofiltrze[klasy == "Cancer",]
    wyniki[i,"cancer mean"] = mean(tempx[,i])
    wyniki[i,"cancer median"] = median(tempx[,i])
    wyniki[i,"cancer SD"] = sd(tempx[,i])

    # Cancer
    tempx = ttpm_pofiltrze[klasy != "Cancer",]
    wyniki[i,"control mean"] = mean(tempx[,i])
    wyniki[i,"control median"] = median(tempx[,i])
    wyniki[i,"control SD"] = sd(tempx[,i])

    # DE
    temp = t.test(ttpm_pofiltrze[,i] ~ as.factor(klasy))
    fc = (temp$estimate[1] - temp$estimate[2])
    wyniki[i,"log10FC (subtr estim)"] = fc
    wyniki[i,"log10FC"] = wyniki[i,"cancer mean"] - wyniki[i,"control mean"]
    wyniki[i,"log2FC"] = wyniki[i,"log10FC"] / log10(2)

    revfc = (temp$estimate[2] - temp$estimate[1])
    wyniki[i,"reversed_log10FC"] = revfc
    wyniki[i,"reverse_log2FC"] = wyniki[i,"reversed_log10FC"] / log10(2)
    #wyniki[i,"log2FC"] = log2(fc)
    wyniki[i,"p-value"] = temp$p.value
  }
  wyniki[,"p-value Bonferroni"] = p.adjust(wyniki$`p-value`, method = "bonferroni")
  wyniki[,"p-value Holm"] = p.adjust(wyniki$`p-value`, method = "holm")
  wyniki[,"-log10(p-value Bonferroni)"] = -log10(p.adjust(wyniki$`p-value`, method = "bonferroni"))
  wyniki[,"p-value BH"] = p.adjust(wyniki$`p-value`, method = "BH")

  wyniki$miR = as.character(wyniki$miR)
  return(wyniki %>% arrange(`p-value BH`))
}

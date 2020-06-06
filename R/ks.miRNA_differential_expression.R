#' ks.miRNA_differential_expression
#'
#' The variable performes standard differential expression analysis using unpaired t-test with BH and Bonferonni correction.
#' It requires `ttpm_pofiltrze` object, which is a matrix of log-transformed TPM-normalized miRNAs counts with miRNAs placed in `ttpm` design (i.e. columns and cases placed as rows).
#' Classess should be passed as `klasy` and this should be a vector of length equal to number of rows in `ttpm_polfiltrze` and contain only "Cancer" or "Control" labels!!
#' The function returns the miRNAs sorted by BH-corrected p-value.
#'
#' @param ttpm_pofiltrze matrix of log-transformed TPM-normalized miRNAs counts with miRNAs placed in `ttpm` design (i.e. columns and cases placed as rows)
#' @param klasy vector describing label for each case. It should contain only "Cancer" and "Control" labeles!!!!
#' @param mode use 'logtpm' for log(TPM) data or 'deltact' for qPCR deltaCt values. This parameters sets how the fold-change is calculated. 
#' 
#' 
#' @return Data frame with results.
#'
#' @export
ks.miRNA_differential_expression = function(ttpm_pofiltrze, klasy, mode = "logtpm")
{
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
  wyniki = data.frame(miR = as.character(colnames(ttpm_pofiltrze)))
  ttpm_pofiltrze = as.data.frame(ttpm_pofiltrze)

  suppressMessages(library(dplyr))

  for (i in 1:length(colnames(ttpm_pofiltrze)))
  {
    # Filtry
    #wyniki[i,"jakieszero"] = ifelse(sum(ttpm_pofiltrze[,i] == 0) > 0, "tak", "nie")

    # Średnia i SD
    wyniki[i,paste0("mean ",mode)] = mean(ttpm_pofiltrze[,i])
    wyniki[i,paste0("median ",mode)] = median(ttpm_pofiltrze[,i])
    wyniki[i,paste0("SD ",mode)] = sd(ttpm_pofiltrze[,i])

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
    if(mode == "logtpm") {
    fc = (temp$estimate[1] - temp$estimate[2])
    wyniki[i,"log10FC (subtr estim)"] = fc
    wyniki[i,"log10FC"] = wyniki[i,"cancer mean"] - wyniki[i,"control mean"]
    wyniki[i,"log2FC"] = wyniki[i,"log10FC"] / log10(2)

    revfc = (temp$estimate[2] - temp$estimate[1])
    wyniki[i,"reversed_log10FC"] = revfc
    wyniki[i,"reversed_log2FC"] = wyniki[i,"reversed_log10FC"] / log10(2)
    #wyniki[i,"log2FC"] = log2(fc)
    }

    if(mode == "deltact") {
    fc = 2 ^ (temp$estimate[1] - temp$estimate[2])
    wyniki[i,"FC"] = fc
    wyniki[i,"log10FC"] = log10(fc)
    wyniki[i,"log2FC"] = log2(fc)

    revfc = 2 ^ (temp$estimate[2] - temp$estimate[1])
    wyniki[i,"reversed_log10FC"] = log10(fc)
    wyniki[i,"reversed_log2FC"] = log2(fc)
    #wyniki[i,"log2FC"] = log2(fc)
    }

    wyniki[i,"p-value"] = temp$p.value
  }
  wyniki[,"p-value Bonferroni"] = p.adjust(wyniki$`p-value`, method = "bonferroni")
  wyniki[,"p-value Holm"] = p.adjust(wyniki$`p-value`, method = "holm")
  # wyniki[,"-log10(p-value Bonferroni)"] = -log10(p.adjust(wyniki$`p-value`, method = "bonferroni"))
  wyniki[,"p-value BH"] = p.adjust(wyniki$`p-value`, method = "BH")

  wyniki$miR = as.character(wyniki$miR)
  return(wyniki %>% arrange(`p-value BH`))
}

#' ks.correct_miRNA_names
#'
#' Sometinmes, when using the dataset mapped to previous versions of miRbase we may get false mismatches due to changes in terminology.
#' This function uses latest version of miRbase to correct all old miRNA names to new one.
#'
#' @param temp Dataset with miRNA names in columns.
#'
#' @return Corrected dataset.
ks.correct_miRNA_names = function(temp, species = "hsa") {
  library(foreach)
  library(doParallel)
  library(dplyr)
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
  miRbase_aliasy = fread("ftp://mirbase.org/pub/mirbase/CURRENT/aliases.txt.gz")
  colnames(miRbase_aliasy) = c("MIMAT","Aliasy")
  miRbase_aliasy_hsa = miRbase_aliasy %>% filter(str_detect(Aliasy, paste0(species,"*"))) %>% filter(str_detect(MIMAT, "MIMAT*"))

  #setup parallel backend to use many processors
  cores=detectCores()
  cl <- makePSOCKcluster(cores-1) #not to overload your computer
  registerDoParallel(cl)

  temp2 = colnames(temp)
  final <- foreach(i=1:length(temp2), .combine=c) %dopar% {
    #for(i in 1:length(temp2)) {
    naz = temp2[i]
    library(data.table)
    library(stringr)
    for (ii in 1:nrow(miRbase_aliasy_hsa)) {
      temp3 = str_split(as.character(miRbase_aliasy_hsa[ii,2]), ";")
      temp4 = temp3[[1]]
      temp4 = temp4[temp4 != ""]
      if(naz %in% temp4) { naz = temp4[length(temp4)] }
    }
    naz
  }

  colnames(temp) = final
  stopCluster(cl)
  return(temp)
}

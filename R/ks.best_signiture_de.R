#' ks.best_signiture_de
#'
#' As a part of checkpoint, you may want to check the differential expression of selected miRNAs. This function uses `ks.miRNA_differential_expression()` to check the miRNAs on training dataset.
#'
#' @param selected_miRNAs Vector of selected miRNAs to be checked.
#' @param use_mix By default (i.e. FALSE) we check the differential expression only on training dataset. If you want to check it on whole dataset (training, testing and validation dataset combined) set it to TRUE.
#'
#' @return Results of differential expression.
#'
#'
#' @export
ks.best_signiture_de = function(selected_miRNAs, use_mix = F)
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
  dane = ks.load_datamix(replace_smote = F); train = dane[[1]]; test = dane[[2]]; valid = dane[[3]]; train_smoted = dane[[4]]; trainx = dane[[5]]; trainx_smoted = dane[[6]]

  wyniki = ks.miRNA_differential_expression(trainx, train$Class)
  #write.csv(wyniki, "DE_tylkotrain.csv")
  if (use_mix ==T) {
    mix = rbind(train,test,valid)
    wyniki = ks.miRNA_differential_expression(dplyr::select(mix,starts_with("hsa")), mix$Class) }
  #write.csv(wynikiw, "DE_wszystko.csv")

  wyniki = wyniki %>% arrange(`p-value`)

  return(wyniki[match(selected_miRNAs, wyniki$miR),c("miR","log2FC","p-value","p-value BH")])
}

setwd("/root/miRNAselector/")
suppressMessages(library(data.table))
suppressMessages(library(dplyr))
dane = fread("data.csv")
dane[dane == ""] = NA

error = FALSE
if("Class" %in% colnames(dane)) { cat("✓ The file contains Class variable. ") } else 
{ stop("The file contains DOES NOT Class variable. ") }

dane$Class = factor(dane$Class, levels = c("Control","Cancer"))
if(table(dane$Class)[1] == 0) { stop("There are no control cases.") }
if(table(dane$Class)[2] == 0) { stop("There are no cancer cases.") }
cat(paste0("\n✓ The data contains ", table(dane$Class)[1], " `Control` cases and ", table(dane$Class)[2], " `Cancer` cases."))

temp = dplyr::select(dane, starts_with("hsa"))
if(ncol(temp)==0) { stop("The data does not contain any features (e.g. miRNAs) for feautre selection. Remember that feature names should start from hsa...") }
cat(paste0("\n✓ The data contains ", ncol(temp), " features (e.g. miRNAs) for selection."))

czy_numeryczne = sapply(temp, is.numeric)
if(sum(czy_numeryczne) != ncol(temp)) { stop("Some of the features are not numeric. Please remove them. Not numeric: ", paste0(colnames(temp)[czy_numeryczne == F], collapse = ", "))}
cat(paste0("\n✓ All features are numeric."))

czy_brakna = sapply(temp, is.na)
if(sum(colSums(czy_brakna)) != 0) 
{ cat("\n✓ Some of the features contain missing data. That's ok. We will complete them using predictive mean matching. With missing values: ", paste0(colnames(temp)[colSums(czy_brakna) > 0], collapse = ", "))}

if("Batch" %in% colnames(dane)) { cat("\n✓ The file contains Batch variable that can be used for batch-effect correction. ") }

fwrite(dane, "data.csv")
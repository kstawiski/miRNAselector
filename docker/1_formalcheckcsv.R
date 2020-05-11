setwd("/miRNAselector/")
suppressMessages(suppressMessages(library(data.table)))
suppressMessages(suppressMessages(library(dplyr)))
dane = fread("data.csv")
colnames(dane) = make.names(colnames(dane), unique = T)
dane[dane == ""] = NA

error = FALSE
if("Class" %in% colnames(dane)) { cat("✓ The file contains Class variable. ") } else 
{ writeLines(as.character("FAIL"), "var_initcheck.txt", sep=""); stop("The file contains DOES NOT Class variable. ") }

dane$Class = factor(dane$Class, levels = c("Control","Cancer"))
if(table(dane$Class)[1] == 0) { writeLines(as.character("FAIL"), "var_initcheck.txt", sep=""); stop("There are no control cases.") }
if(table(dane$Class)[2] == 0) { writeLines(as.character("FAIL"), "var_initcheck.txt", sep=""); stop("There are no cancer cases.") }
cat(paste0("\n✓ The data contains ", table(dane$Class)[1], " `Control` cases and ", table(dane$Class)[2], " `Cancer` cases."))

temp = dplyr::select(dane, starts_with("hsa"))
if(ncol(temp)==0) { writeLines(as.character("FAIL"), "var_initcheck.txt", sep=""); stop("The data does not contain any features (e.g. miRNAs) for feautre selection. Remember that feature names should start from hsa...") }
cat(paste0("\n✓ The data contains ", ncol(temp), " features (e.g. miRNAs) for selection."))

czy_numeryczne = sapply(temp, is.numeric)
if(sum(czy_numeryczne) != ncol(temp)) { writeLines(as.character("FAIL", "var_initcheck.txt", sep = "")); stop("Some of the features are not numeric. Please remove them. Not numeric: ", paste0(colnames(temp)[czy_numeryczne == F], collapse = ", "))}
cat(paste0("\n✓ All features are numeric."))

missing = FALSE
czy_brakna = sapply(temp, is.na)
if(sum(colSums(czy_brakna)) != 0) 
{ cat("\n✓ Some of the features contain missing data. That's ok. We will impute missing values.\nWith missing values:\n  -", paste0(colnames(temp)[colSums(czy_brakna) > 0], collapse = "\n  - "))
missing = T } else 
{ cat(paste0("\n✓ There are no missing data in features.")) }

batch = F
if("Batch" %in% colnames(dane)) { cat("\n✓ The file contains `Batch` variable that can be used for batch-effect correction. Please check if the following contingency table is correct:\n ")
print(table(dane$Class, dane$Batch))
batch = T } else { cat("\n✓ The file does not contain `Batch` variable that can be used for batch-effect correction. Batch correction will be omitted.") }

x = dplyr::select(dane, starts_with("hsa"))
like_counts = sapply(x, function(x2) (sum(unlist(na.omit(x2))%%1 == 0) + sum(unlist(na.omit(x2)) >= 0))/(2*length(unlist(na.omit(x2)))) == 1)
positive = F
if(like_counts) { cat("\n✓ Feature values are positive integers. The file could represent read counts (the normalization functions can be applied)."); positive = T; } else {
    cat("\n✓ Feature values are not positive integers. The functions for normalization of the read counts will be disabled.");
}
writeLines(as.character(positive), "var_seemslikecounts.txt", sep="")


if(!file.exists("data_start.csv")) { fwrite(dane, "data_start.csv") }
# Out: czy missing,czy batch
writeLines(as.character(batch), "var_batch.txt", sep="")
writeLines(as.character(missing), "var_missing.txt", sep="")
writeLines("OK", "var_initcheck.txt", sep="")
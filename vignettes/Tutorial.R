## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE, message=FALSE, warning=FALSE,
  comment = "#>"
)
knitr::opts_chunk$set(fig.width=12, fig.height=8)
knitr::opts_chunk$set(tidy.opts=list(width.cutoff=150),tidy=TRUE)
options(rgl.useNULL = TRUE)
options(warn=-1)
suppressMessages(library(dplyr))
set.seed(1)
options(knitr.table.format = "html")
library(miRNAselector)

## -----------------------------------------------------------------------------
readLines("setup.R") %>% paste0(collapse="\n") %>% cat

## ----setup--------------------------------------------------------------------
library(miRNAselector)

## ---- eval = F----------------------------------------------------------------
#  ks.download_tissue_miRNA_data_from_TCGA()
#  ks.process_tissue_miRNA_TCGA(remove_miRNAs_with_null_var = T)

## -----------------------------------------------------------------------------
suppressWarnings(suppressMessages(library(data.table)))
suppressWarnings(suppressMessages(library(knitr)))
data("orginal_TCGA_data")
ks.table(table(orginal_TCGA_data$primary_site, orginal_TCGA_data$sample_type))

## -----------------------------------------------------------------------------
suppressWarnings(suppressMessages(library(dplyr)))

cancer_cases = filter(orginal_TCGA_data, primary_site == "Pancreas" & sample_type == "PrimaryTumor")
control_cases = filter(orginal_TCGA_data, sample_type == "SolidTissueNormal")

## -----------------------------------------------------------------------------
cancer_cases$Class = "Cancer"
control_cases$Class = "Control"

dataset = rbind(cancer_cases, control_cases)

ks.table(table(dataset$Class), col.names = c("Class","Number of cases"))

## -----------------------------------------------------------------------------
boxplot(dataset$age_at_diagnosis ~ dataset$Class)
t.test(dataset$age_at_diagnosis ~ dataset$Class)
ks.table(table(dataset$gender.x, dataset$Class))
chisq.test(dataset$gender.x, dataset$Class)

## -----------------------------------------------------------------------------
old_dataset = dataset # backup
dataset = dataset[grepl("Adenocarcinomas", dataset$disease_type),]
match_by = c("age_at_diagnosis","gender.x")
tempdane = dplyr::select(dataset, match_by)
tempdane$Class = ifelse(dataset$Class == "Cancer", TRUE, FALSE)
suppressMessages(library(mice))
suppressMessages(library(MatchIt))
temp1 = mice(tempdane, m=1)
temp2 = temp1$data
temp3 = mice::complete(temp1)
temp3 = temp3[complete.cases(temp3),]
tempform = ks.create_miRNA_formula(match_by)
mod_match <- matchit(tempform, data = temp3)
newdata = match.data(mod_match)
dataset = dataset[as.numeric(rownames(newdata)),]


## -----------------------------------------------------------------------------
boxplot(dataset$age_at_diagnosis ~ dataset$Class)
t.test(dataset$age_at_diagnosis ~ dataset$Class)
ks.table(table(dataset$gender.x, dataset$Class))
chisq.test(dataset$gender.x, dataset$Class)
fwrite(dataset, "balanced_dataset.csv.gz")


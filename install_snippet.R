old_packages <- installed.packages(lib.loc = "~/R/x86_64-pc-linux-gnu-library/3.6/")
install.packages(old_packages[,1])

library("devtools")
source_url("https://raw.githubusercontent.com/kstawiski/miRNAselector/master/vignettes/setup.R")
install_github("kstawiski/miRNAselector", force = T)
library(miRNAselector)



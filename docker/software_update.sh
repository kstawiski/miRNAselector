#!/bin/bash
echo "Starting update..." 2>&1 | tee /update.log
date 2>&1 | tee -a /update.log
cd /miRNAselector/miRNAselector
git reset --hard 2>&1 | tee -a /update.log
git clean -df 2>&1 | tee -a /update.log
git pull 2>&1 | tee -a /update.log
Rscript --verbose -e 'library(remotes); library(devtools); update.packages(ask = F); library(BiocManager); install(ask = F); source_url("https://raw.githubusercontent.com/kstawiski/miRNAselector/master/vignettes/setup.R"); remotes::install_github("kstawiski/miRNAselector", force = T);' 2>&1 | tee -a /update.log
echo "The update is finished. Please go back to the app." 2>&1 | tee -a /update.log
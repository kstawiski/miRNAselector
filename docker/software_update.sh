#!/bin/bash
echo "Starting update..." 2>&1 | tee /update.log
date 2>&1 | tee -a /update.log
cd /miRNAselector/miRNAselector
git reset --hard 2>&1 | tee -a /update.log
git clean -df 2>&1 | tee -a /update.log
git pull 2>&1 | tee -a /update.log
conda --update all 2>&1 | tee -a /update.log
Rscript --verbose -e 'update.packages(ask = F); BiocManager::install(ask = F);' 2>&1 | tee -a /update.log
Rscript --verbose -e 'source("vignettes/setup.R"); devtools::install_github("kstawiski/miRNAselector", force = T);' 2>&1 | tee -a /update.log
echo "The update is finished. Please go back to the app." 2>&1 | tee -a /update.log
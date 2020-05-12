#!/bin/bash
echo "Starting update..." | tee /update.log
date | tee -a /update.log
cd /miRNAselector/miRNAselector
git reset --hard | tee -a /update.log
git clean -df | tee -a /update.log
git pull | tee -a /update.log
Rscript -e 'library(devtools); BiocManager::install(ask = F); install_github("kstawiski/miRNAselector", force=TRUE)' | tee -a /update.log
echo "The update is finished. Please go back to the app." | tee -a /update.log
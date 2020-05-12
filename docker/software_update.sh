#!/bin/bash
echo "Starting update..." 2>&1 | tee /update.log
date 2>&1 | tee -a /update.log
cd /miRNAselector/miRNAselector
git reset --hard 2>&1 | tee -a /update.log
git clean -df 2>&1 | tee -a /update.log
git pull 2>&1 | tee -a /update.log
Rscript -e 'library(devtools); BiocManager::install(ask = F); install_github("STATWORX/bounceR"); install_github("Thie1e/cutpointr"); install_github("vqv/ggbiplot"); install_github("kstawiski/miRNAselector", force=TRUE)' 2>&1 | tee -a /update.log
echo "The update is finished. Please go back to the app." 2>&1 | tee -a /update.log
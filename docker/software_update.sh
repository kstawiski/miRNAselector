#!/bin/bash
echo "Starting update..." 2>&1 | tee /update.log
date 2>&1 | tee -a /update.log
cd /miRNAselector/miRNAselector
git reset --hard 2>&1 | tee -a /update.log
git clean -df 2>&1 | tee -a /update.log
git pull 2>&1 | tee -a /update.log
Rscript -e 'devtools::install_github("kstawiski/miRNAselector", upgrade = "never");' 2>&1 | tee -a /update.log
# Rscript --verbose -e 'source("/miRNAselector/miRNAselector/docker/keras.R");' 2>&1 | tee -a /update.log
git rev-parse --short HEAD | tee /version.txt
echo "The update is finished. Please go back to the app." 2>&1 | tee -a /update.log
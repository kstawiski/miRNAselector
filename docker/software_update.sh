#!/bin/bash
echo "Starting update..."
date
cd /miRNAselector/miRNAselector
git reset --hard 
git clean -df
git pull
Rscript -e 'devtools::install_github("kstawiski/miRNAselector", force=TRUE)'
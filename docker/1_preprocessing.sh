#!/bin/bash
echo "Starting preprocessing..." 2>&1 | tee /miRNAselector/1_preprocessing.log
date 2>&1 | tee -a /miRNAselector/1_preprocessing.log
cd /miRNAselector/
Rscript --verbose -e 'library(miRNAselector); library(rmarkdown); ' 2>&1 | tee -a /update.log
echo "-- miRNAselector_finished --" 2>&1 | tee -a /update.log
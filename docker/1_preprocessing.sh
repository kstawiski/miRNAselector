#!/bin/bash
set -e
# Task:
echo "Preprocessing" > /task-name.txt

# Process:
echo "Starting task..." 2>&1 | tee /task.log
date 2>&1 | tee -a /task.log
cd /miRNAselector/
Rscript -e 'file.copy("/miRNAselector/miRNAselector/templetes/1_preprocessing.rmd", "/miRNAselector/1_preprocessing.Rmd", overwrite = TRUE)'
Rscript -e 'rmarkdown::render("/miRNAselector/1_preprocessing.Rmd", output_file = "1_preprocessing.html", output_dir = "/miRNAselector")' 2>&1 | tee -a /task.log

# Ending:
Rscript -e 'file.copy("/task.log", "/miRNAselector/1_preprocessing.Rmd", overwrite = TRUE)'
echo "[miRNAselector: TASK COMPLETED]" 2>&1 | tee -a /task.log
echo "[2] PREPROCESSED" > /miRNAselector/var_status.txt
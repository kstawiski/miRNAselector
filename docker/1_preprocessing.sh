#!/bin/bash
set -e
# Task:
echo "Preprocessing" > /task-name.txt

# Process:
echo "Starting task..." 2>&1 | tee /task.log
date 2>&1 | tee -a /task.log
cd /miRNAselector/
Rscript -e '
    library(rmarkdown);
    file.copy("/miRNAselector/miRNAselector/templetes/1_preprocessing.rmd", "/miRNAselector/1_preprocessing.Rmd", overwrite = TRUE);
    render("/miRNAselector/1_preprocessing.Rmd", output_file = "1_preprocessing.html", output_dir = "/miRNAselector");
    file.copy("/task.log", "/miRNAselector/1_preprocessing.Rmd", overwrite = TRUE);
    cat("[miRNAselector: TASK COMPLETED]"); writeLines("[2] PREPROCESSED", "var_status.txt", sep="");
    ' 2>&1 | tee -a /task.log
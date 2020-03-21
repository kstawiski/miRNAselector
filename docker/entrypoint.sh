#!/bin/bash
cd /root/miRNAselector/
git clone git@github.com:kstawiski/miRNAselector.git
cp miRNAselector/templetes/Analysis.rmd Analysis.rmd
Rscript /update.R
jupyter serverextension enable jupytext
jupyter notebook Analysis.ipynb --no-browser
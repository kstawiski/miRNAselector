#!/bin/bash
cd /root/miRNAselector/
git clone https://github.com/kstawiski/miRNAselector.git
cp miRNAselector/templetes/Analysis.Rmd Analysis.Rmd
Rscript /update.R
jupyter serverextension enable jupytext
jupyter notebook --no-browser
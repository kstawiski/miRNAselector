#!/bin/bash
cd /root/miRNAselector/
git clone https://github.com/kstawiski/miRNAselector.git
chmod -R 755 /root/miRNAselector/miRNAselector/static/
/usr/sbin/nginx -g "daemon off;" &
mkdir -p /run/
mkdir -p /run/php/
php-fpm7.3 -R -F &
cp miRNAselector/templetes/Analysis.rmd Analysis.Rmd
Rscript /update.R
jupyter serverextension enable jupytext
jupyter notebook --no-browser
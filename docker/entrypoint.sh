#!/bin/bash
Rscript /update.R
cd /miRNAselector/
git clone https://github.com/kstawiski/miRNAselector.git
chmod -R 755 /miRNAselector/miRNAselector/static/
/usr/sbin/nginx -g "daemon off;" &
mkdir -p /run/
mkdir -p /run/php/
php-fpm7.3 -R -F &
jupyter serverextension enable jupytext
jupyter notebook --no-browser
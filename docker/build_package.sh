#!/bin/bash
echo "Starting building..." 2>&1 | tee /build.log
cd /miRNAselector/miRNAselector
git pull 2>&1 | tee -a /build.log
cd /miRNAselector
date 2>&1 | tee -a /build.log
R CMD build miRNAselector 2>&1 | tee -a /build.log
R CMD check miRNAselector 2>&1 | tee -a /build.log
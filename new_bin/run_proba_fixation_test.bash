#!/usr/bin/env bash

module unload python/3.7
module load msprime/1.1.1
module load pyslim/0.700
module load slim/4.0.1

# Script to generate $1 sweeps using conditional SLiM script "proba_fixation_test.slim"
START=1
END=$1

for (( sweep_number=$START; sweep_number<=$END; sweep_number++ ));do

    echo "Sweep Number $sweep_number -"
    slim -t -m  ./proba_fixation_test.slim

done

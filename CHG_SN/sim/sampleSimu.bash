#!/bin/bash

# $1 = number of simu to sample

mkdir sampledSim
cd sampledSim
destination=$PWD
cd ..

for folder in $(ls -I 'sample*'); do

    # Sample sweep simulations

    for simu in $(ls $folder/results/|grep .ms |cut -f1 -d.|head -n $1); do
        cp --parents $folder/results/${simu}_parameters.txt $destination
        cp --parents $folder/results/${simu}_positions.txt $destination
        cp --parents $folder/results/${simu}_sumStats.txt $destination
        cp --parents $folder/results/${simu}.ms $destination

        echo "- $folder - SWEEP $simu - MOVED -"
    done

        # Sample neutral simulations

    for simu in $(ls $folder/results_Neutral/|grep .ms |cut -f1 -d.|head -n $1); do
        cp --parents $folder/results_Neutral/${simu}_parameters.txt $destination
        cp --parents $folder/results_Neutral/${simu}_positions.txt $destination
        cp --parents $folder/results_Neutral/${simu}_sumStats.txt $destination
        cp --parents $folder/results_Neutral/${simu}.ms $destination

        echo "- $folder - NEUTRAL $simu - MOVED -"
    done
done

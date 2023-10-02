#!/usr/bin/env bash

# Run this on each subfolder
# To generate range_stats.txt files

module load opencv

# Path to the parameters directory
SIMULATIONS_DIR="../simulations"
STARTING_PWD=$PWD

# Loop through each subfolder in the parameters directory
for subfolder in $(ls $SIMULATIONS_DIR | grep -E 'BTL|CST|EXP|MGB|MGX|MIG'); do
    if [ -d "$subfolder" ]; then
        echo "SIMULATION FOLDER: $(basename "$subfolder")"

            cd $SIMULATIONS_DIR/$subfolder
			firstSimulation=$(ls | grep -E 'BTL|CST|EXP|MGB|MGX|MIG' | head -n 1 | cut -d_ -f1)
sbatch --wrap="python ../../new_bin/sim2box_single_YOLOv5.py dpi=300 datapath=$PWD simulation=$firstSimulation object=posSelection theta=0 phasing=1 plotStats=0 getAllData=1 modelSim=both target_res=512"

            cd $STARTING_PWD
        echo -e "FOLDER - DONE: $(basename "$subfolder")\n"
    fi
done

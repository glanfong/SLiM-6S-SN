#!/bin/bash

# Script Used to Launch the creation of pictures and corresponding bbox using slurm-array
# When launching this script, first positional argument = number of simultaneous tasks to launch
# bash launch_sim2box_array.bash 10
# Will launch launch_sim2box_array jobs, 1 job per subdirectory
# and up to 10 simultaneous jobs per subdirectory (so 10 recapitations)

# Path to the parameters directory
SIMULATIONS_DIR="../simulations"
STARTING_PWD=$PWD

# Loop through each subfolder in the parameters directory
for subfolder in $(ls $SIMULATIONS_DIR | grep -E 'BTL|CST|EXP|MGB|MGX|MIG'); do
    echo "PARAMETERS FOLDER: $(basename "$subfolder")"

        cp ./sim2box_run_array.slurm $SIMULATIONS_DIR/$subfolder/

        cd $SIMULATIONS_DIR/$subfolder

        mkdir -p stdout

        sbatch --array=0-$(ls *sweep_sumStats.txt | wc -l)%$1 sim2box_run_array.slurm

        cd $STARTING_PWD
    echo -e "FOLDER - DONE: $(basename "$subfolder")\n"
done

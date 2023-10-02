#!/bin/bash
 
# Script Used to Launch the recapitation using slurm-array
# When launching this script, first positional argument = number of simultaneous tasks to launch 
# bash launch_recap_array.bash 10
# Will launch slurm_array jobs, 1 job per subdirectory
# and up to 10 simultaneous jobs per subdirectory (so 10 recapitations)

# Path to the parameters directory
SIMULATIONS_DIR="../simulations"
STARTING_PWD=$PWD

# Loop through each subfolder in the parameters directory
for subfolder in "$SIMULATIONS_DIR"/*; do
    if [ -d "$subfolder" ]; then
        echo "PARAMETERS FOLDER: $(basename "$subfolder")"
        
            cp ./recap-SIM_run_array.slurm $SIMULATIONS_DIR/$subfolder/

            cd $SIMULATIONS_DIR/$subfolder

	    mkdir -p stdout

            sbatch --array=0-$(ls *.trees | wc -l)%$1 recap-SIM_run_array.slurm

            cd $STARTING_PWD
        echo -e "FOLDER - DONE: $(basename "$subfolder")\n"
    fi
done

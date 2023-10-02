#!/bin/bash
 
# Script Used to Launch the SLiM simulations using slurm-array
# When launching this script, first positional argument = number of simultaneous tasks to launch 
# bash launch_SLIM_array.bash 10
# Will launch slurm_array jobs, 1 job per subdirectory
# and up to 10 simultaneous jobs per subdirectory (so 10 SLiM simulations)

# Path to the parameters directory
PARAMETERS_DIR="../parameters"
STARTING_PWD=$PWD

# Loop through each subfolder in the parameters directory
for subfolder in "$PARAMETERS_DIR"/*; do
    if [ -d "$subfolder" ]; then
        echo "PARAMETERS FOLDER: $(basename "$subfolder")"
        
            cp ./SLiM-SIM_run_array.slurm $PARAMETERS_DIR/$subfolder/

            cd $PARAMETERS_DIR/$subfolder

	    mkdir -p stdout

            sbatch --array=0-$(ls *prior_parameters.txt | wc -l)%$1 SLiM-SIM_run_array.slurm

            cd $STARTING_PWD
        echo -e "FOLDER - DONE: $(basename "$subfolder")\n"
    fi
done


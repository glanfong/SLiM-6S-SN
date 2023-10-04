#!/usr/bin/env bash

module unload python/3.7
module load msprime/1.2.0
module load pyslim/1.0.1
module load tskit/0.5.3
module load slim

# Path to the SLiM_run.sh script
SLIM_RUN_SCRIPT="./SLiM_run.sh"

# Path to the parameters directory
PARAMETERS_DIR="../parameters"

# Loop through each subfolder in the parameters directory
for subfolder in $(ls $SIMULATIONS_DIR | grep -E 'BTL|CST|EXP|MGB|MGX|MIG'); do
    echo "RUNNING SIMULATIONS - FOLDER: $(basename "$subfolder")"
    
    # Get the parameter files inside the subfolder
    parameter_files=("$subfolder"/*_prior_parameters.txt)
    
    # Loop through each parameter file in the subfolder
    for parameter_file in "${parameter_files[@]}"; do
        echo "PARAMETER FILE: $(basename "$parameter_file")"
        
        # Run SLiM_run.sh script with the parameter file
        bash "$SLIM_RUN_SCRIPT" "$parameter_file"
        
        echo -e "PARAMETER FILE - DONE: $(basename "$parameter_file")\n"
    done
    
    echo "FOLDER - DONE: $(basename "$subfolder")"
    echo
done

echo "All simulations finished!"

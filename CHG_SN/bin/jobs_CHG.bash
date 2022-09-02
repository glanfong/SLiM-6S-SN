#!/usr/bin/bash

# Keywords : run simulations SLiM bash demographic change selective sweep ifb core cluster jobs slurm

# Run multiple jobs for SLiM simulations (6S CHG/MGD) on ifb core cluster
# One job will be launch for each parameters[x].txt file

# RUN ON IFB CLUSTER #

# for paramFile in $(ls ./parameters/ | grep 'parameters*..txt'); do
#         sbatch --wrap="bash ./launch_run.bash $paramFile"
# done


# RUN ON LOCAL DESKTOP #

for paramFile in $(ls ./parameters/ | grep 'parameters*..txt'); do
        bash ./launch_run.bash $paramFile
done
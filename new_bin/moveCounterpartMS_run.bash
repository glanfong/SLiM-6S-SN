# Run noCounterpartMS.bash on every subfolders

# Path to the simulation directory
SIMULATIONS_DIR="../simulations"
STARTING_PWD=$PWD

# Loop through each subfolder in the simulation directory
for subfolder in $(ls "../simulations/" | grep -E 'BTL|CST|EXP|MGB|MGX|MIG'); do
    echo "SIMULATION FOLDER: $(basename "$subfolder")"

        cd $SIMULATIONS_DIR/$subfolder

        cp $STARTING_PWD/moveCounterpartMS.bash .
        bash moveCounterpartMS.bash

        cd $STARTING_PWD


    echo -e "FOLDER - MS NO COUNTERPART MOVED: $(basename "$subfolder")\n"
done

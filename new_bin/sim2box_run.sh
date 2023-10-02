#!/usr/bin/env bash

# À lancer depuis le dossier contenant les .trees files

# Get the path to the parameters.txt and the .trees file from the command-line argument
SUMSTAT_FILE="$1"
iteration=$(echo $SUMSTAT_FILE | cut -d_ -f1)
SIM2BOX_SCRIPT_PATH="../../new_bin/"

############################################
# PARAMETERS TO MANUALLY CHANGE IF ANOTHER #
#            PICTURE SIZE IS NEEDED        #
############################################

dpi=300
target_res=500
target_res="$((target_res+26))"

############################################

# Loop through each parameter line in the input file

echo "### STARTING SIM2BOX ###"

# Run sim2box on both sweep and neutral simulations

$SUMSTAT_FILE

echo -e " - SIM2BOX - $(echo $SUMSTAT_FILE) - "
python $SIM2BOX_SCRIPT_PATH/sim2box_single_YOLOv5.py dpi=300 datapath=$PWD simulation=${iteration} object=posSelection theta=0 phasing=1 plotStats=0 getAllData=0 modelSim=both target_res=${target_res} 

echo -e "- SIM2BOX - $(echo $SUMSTAT_FILE) DONE -"

echo "### SIM2BOX FINISHED ###"

#!/usr/bin/env bash

# À lancer depuis le dossier contenant les .ms files

# Get the path to the .ms file from the command-line argument
MS_FILE=$(echo "$1" | cut -d/ -f10)
STATCALC_RUN_SCRIPT="../../new_bin/"

# Get the path to the .ms file from the command-line argument
iteration=$(echo $MS_FILE | cut -d_ -f1)
model=$(echo $MS_FILE | cut -d_ -f2 | cut -d. -f1)


echo "### COMPUTING STATS ###"
echo -e " - STATS - $(echo $MS_FILE | cut -d/ -f10) - "

echo ${iteration}_${model}
python3 $STATCALC_RUN_SCRIPT/msmscalc_onePop.py infile=${iteration}_${model}.ms nIndiv=40 nCombParam=1 regionSize=100000 width=0.01 step=0.005 nRep=1 root=${iteration}_${model}

echo -e "- STATS - $(echo $MS_FILE | cut -d/ -f10) DONE -"


echo "### RECAPITATION FINISHED ###"

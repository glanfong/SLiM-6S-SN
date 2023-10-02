#!/usr/bin/env bash

# À lancer depuis le dossier contenant les .ms files

# Get the path to the .ms file from the command-line argument
MS_FILE="$1"

STATCALC_RUN_SCRIPT="../../new_bin/"

# Loop through each parameter line in the input file

iteration=$(echo $MS_FILE | cut -d_ -f1)

echo "### COMPUTING STATS ###"
echo -e " - STATS - $(echo $MS_FILE | cut -d/ -f4) - "

for model in neutral sweep; do
	echo ${iteration}_${model}
	python3 $STATCALC_RUN_SCRIPT/msmscalc_onePop.py infile=${iteration}_${model}.ms nIndiv=40 nCombParam=1 regionSize=100000 width=0.01 step=0.005 nRep=1 root=${iteration}_${model}
done

echo -e "- STATS - $(echo $MS_FILE | cut -d/ -f4) DONE -"


echo "### RECAPITATION FINISHED ###"

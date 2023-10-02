#!/usr/bin/env bash

# À lancer depuis le dossier contenant les .trees files

# Get the path to the parameters.txt and the .trees file from the command-line argument
TREE_FILE="$1"
PARAM_FILE="$2"
RESULTS_PARAM_FILE="$3"

RECAP_SCRIPT_PATH="../../new_bin/"

while IFS=$'\t' read -r line; do
    # Skip lines starting with #
    if [[ $line == "#sim_id"* ]]; then
        continue
    fi

    # Split the line into variables using tab as the delimiter
    IFS=$'\t' read -r sim_id outcome NeA NeB s r mu L m mut_pos rise_gen fix_gen SLiM_gen samp mut_freq run_CPU_time chg_r split_gen chg_gen mig_gen <<< "$line"

done < "$RESULTS_PARAM_FILE"

# Loop through each parameter line in the input file
while IFS=$'\t' read -r line; do
    # Skip lines starting with #
    if [[ $line == "#"* ]]; then
        continue
    fi
    
    # Split the line into variables using tab as the delimiter
    IFS=$'\t' read -r id Ne_anc NeA r mu L samp chg_r split_gen chg_gen mig_gen SLiM_gen m m_chg selection_coefficient<<< "$line"

    echo "### STARTING RECAPITATION ###"

    # Run SLiM simulations as long as the parameters.txt output file isn't created

    echo -e " - RECAP - $(echo $TREE_FILE | cut -d/ -f4) - "
    python $RECAP_SCRIPT_PATH/recapitation_SLiM_SiM.py $TREE_FILE $Ne_anc $NeA $r $mu $m $m_chg $SLiM_gen $mig_gen $chg_gen $split_gen $samp $mut_pos $L

    echo -e "- RECAP - $(echo $TREE_FILE | cut -d/ -f4) DONE -"

done < "$PARAM_FILE"

echo "### RECAPITATION FINISHED ###"


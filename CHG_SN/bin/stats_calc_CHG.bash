#!/usr/bin/bash

# Keywords : stats calc simulations SLiM bash expansion CHG

# Run msmscalc_onePop.py based on the contents of prior.txt and msmscalc_param.txt files

# /!\ HAS to be launch from within "results" folder /!\ 

# POSITIONAL ARGUMENT $1 = window_size / $2 = step / $3 = "sweep" or "neutral"

module load python/3.7

{
read
 while IFS= read -r line; do
    id=$(echo "$line" | cut -d$'\t' -f1)
    NeA=$(echo "$line" | cut -d$'\t' -f3)
    NeB=$(echo "$line" | cut -d$'\t' -f4)
    r=$(echo "$line" | cut -d$'\t' -f6)
    mu=$(echo "$line" | cut -d$'\t' -f7)
    L=$(echo "$line" | cut -d$'\t' -f8)
    m=$(echo "$line" | cut -d$'\t' -f9)
    samp=$(echo "$line" | cut -d$'\t' -f14)
    chg_r=$(echo "$line" | cut -d$'\t' -f17)
    split_gen=$(echo "$line" | cut -d$'\t' -f18)

# Step 3 : use msmscalc_onePop.py to compute summary statistics of the population

    nIndividuals=$((${samp}*2)) # number of HAPLOID individuals
    nReplicates=1

    window_size=$1
    step=$2
    selection_regime=$3

    # echo -e "window_size\tstep\tselection_regime" >> stats_calc_window.txt
    echo -e "${window_size}\t${step}\t${selection_regime}" >> stats_calc_window.txt


    echo "- statistics computing - sim_id ${id} -"
    python3 ../../../bin/msmscalc_onePop.py ./${id} ${nIndividuals} 1 ${L} ${window_size} ${step} $nReplicates ${id} ${selection_regime}
    echo "- statistics computed - sim_id ${id} "
    echo -e "- ## Replica ${id} DONE ## -\n"

    done 
} < ./summary.txt

echo -e "\n### STATISTICS COMPUTED ###\n"

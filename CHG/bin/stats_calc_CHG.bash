#!/usr/bin/bash

# Keywords : stats calc simulations SLiM bash expansion CHG

# Run msmscalc_onePop.py based on the contents of prior.txt and msmscalc_param.txt files

# /!\ HAS to be launch from within "results" folder /!\ 

#conda deactivate # deactivate conda environnement in order to use python 3.7

{
read
 while IFS= read -r line; do
    id=$(echo "$line" | cut -d$'\t' -f1)
    Ne=$(echo "$line" | cut -d$'\t' -f3)
    r=$(echo "$line" | cut -d$'\t' -f5)
    mu=$(echo "$line" | cut -d$'\t' -f6)
    L=$(echo "$line" | cut -d$'\t' -f7)
    samp=$(echo "$line" | cut -d$'\t' -f13)
    Ne_init=$(echo "$line" | cut -d$'\t' -f16)

# Step 2 : use trees2ms.py to create an ms output based on a "samp" number of individuals

    echo -e "- trees2ms - sim_id ${id} -"
    python ../../../bin/trees2ms_CHG.py id=${id} Ne_init=${Ne_init} r=${r} mu=${mu} L=${L} samp=${samp}
    echo -e "- ms created - sim_id ${id} -"

    nIndividuals=$((${samp}*2)) # number of HAPLOID individuals
    nb_pop=1 # CHG simulations contain only 1 (one) population

    window_size=$1
    step=$2

    echo "- statistics computing - sim_id ${id} -"
    python3  ../../../bin/msmscalc_onePop.py ./${id}.ms ${nIndividuals} ${nb_pop} ${L} ${window_size} ${step} ${id};
    echo "- statistics computed - sim_id ${id} "
    echo -e "- ## Replica ${id} DONE ## -\n"

    done 
} < ./summary.txt

echo -e "\n### STATISTICS COMPUTED ###\n"

#conda activate glanfong # reactivate conda environnement
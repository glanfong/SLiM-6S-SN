#!/usr/bin/bash

# Keywords : recap recapitation simulations SLiM bash ms CHG

# Run trees2ms.py to recapitate the simulated trees and to create ms based on a "samp" number of individuals

# /!\ HAS to be launch from within "results" folder /!\ 

#conda deactivate # deactivate conda environnement in order to use python 3.7

# POSITIONAL ARGUMENT : $1 = 'sweep' or 'neutral'

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
    chg_gen=$(echo "$line" | cut -d$'\t' -f19)

# Step 2 : use trees2ms.py to recapitate the trees and create an ms output based on a "samp" number of individuals

    echo -e "- trees2ms - sim_id ${id} -"
    python3 ../../../bin/trees2ms_CHG.py selection=$1 id=${id} NeA=${NeA} NeB=${NeB} r=${r} mu=${mu} L=${L} m=${m} samp=${samp} chg_r=${chg_r} split_gen=${split_gen} chg_gen=${chg_gen}
    echo -e "- ms created - sim_id ${id} -\n "

    done 
} < ./summary.txt

echo -e "\n### TREES RECAPITED AND MS FILES CREATED ###\n"

#conda activate glanfong # reactivate conda environnement
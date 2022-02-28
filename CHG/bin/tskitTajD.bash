#!/usr/bin/bash

# Keywords : stats calc simulations SLiM bash expansion CHG

# Run msmscalc_onePop.py based on the contents of prior.txt and msmscalc_param.txt files

# /!\ HAS to be launch from within "results" folder /!\ 

{
read
 while IFS= read -r line; do
    id=$(echo "$line" | cut -d$'\t' -f1)
    echo "- Computing Tajima's D - sim_id ${id} -"
    python3  ../../../bin/treesTajimas_D.py id=${id};

    done 
} < ./summary.txt

echo -e "\n### STATISTICS COMPUTED ###\n"
#!/usr/bin/bash

# Keywords : run simulations SLiM bash constant MGD

# Parameters run launch
# Has to be launched from MGD/bin

# DEFINE binpath #
MGDbinpath=$(pwd)

module unload python/3.7
module load msprime/1.1.1
module load pyslim/0.700
module load slim/3.7.1

# Keywords : run simulations SLiM bash demographic change MGD

# Run MGD-SIM.slim based on the contents of prior.txt file

echo -e "### READING PARAMETERS ###\n"

while IFS= read -r line; do
    NeMin=$(echo "$line" | cut -d$'\t' -f1)
    NeMax=$(echo "$line" | cut -d$'\t' -f2)
    r=$(echo "$line" | cut -d$'\t' -f3)
    mu=$(echo "$line" | cut -d$'\t' -f4)
    L=$(echo "$line" | cut -d$'\t' -f5)
    samp=$(echo "$line" | cut -d$'\t' -f6)
    chg_r=$(echo "$line" | cut -d$'\t' -f7)
    n_rep=$(echo "$line" | cut -d$'\t' -f8)

    bash run_MGD.bash ${NeMin} ${NeMax} ${r} ${mu} ${L} ${samp} ${chg_r} ${n_rep}
done < <(grep -v "#" ./parameters/$1)

echo -e "### SIMULATION COMPLETED ###\n"
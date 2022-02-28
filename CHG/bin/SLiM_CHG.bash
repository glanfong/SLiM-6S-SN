#!/usr/bin/bash

# Keywords : run simulations SLiM bash demographic change CHG

# Run CHG-SIM.slim based on the contents of prior.txt file

echo -e "### STARTING SIMULATIONS ###\n"

printf "sim_id\toutcome\tNe\ts\tr\tmu\tL\tmut_pos\tchg_gen\trise_gen\tfix_gen\tend_gen\tsamp\tmut_freq\ttime(s)\tNe_init\n" >> summary.txt
printf "sim_id\toutcome\tNe\ts\tr\tmu\tL\tmut_pos\tchg_gen\trise_gen\tloss_gen\tend_gen\tsamp\tmut_freq\ttime(s)\tNe_init\n" >> log.txt

{
read
 while IFS= read -r line; do
    id=$(echo "$line" | cut -d$'\t' -f1)
    Ne_min=$(echo "$line" | cut -d$'\t' -f2)
    Ne_max=$(echo "$line" | cut -d$'\t' -f3)
    r=$(echo "$line" | cut -d$'\t' -f4)
    mu=$(echo "$line" | cut -d$'\t' -f5)
    L=$(echo "$line" | cut -d$'\t' -f6)
    samp=$(echo "$line" | cut -d$'\t' -f7)
    chg_r=$(echo "$line" | cut -d$'\t' -f8)


# Step 1 : run SLiM simulations using prior.txt parameters

    echo -e "- SLiM simulating - sim_id ${id} -"
    slim -t -m -d sim_id=${id} -d Ne_min=${Ne_min} -d Ne_max=${Ne_max} -d r=${r} -d mu=${mu} -d L=$((${L}-1)) -d samp=${samp} -d chg_r=${chg_r} ../../../bin/CHG-SIM.slim > /dev/null
    echo -e "- SLiM simulation ${id} done -\n"

    # update summary file
    echo -e "- updating summary file -"
    cat "${id}_parameters.txt" >> summary.txt
    echo -e "- summary file updated -\n"

    done 
} < ../param/prior.txt

echo -e "### SIMULATIONS FINISHED ###\n"

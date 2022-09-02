#!/usr/bin/bash

# Keywords : run simulations SLiM bash demographic change CHG

# Run CHG-SIM.slim based on the contents of prior.txt file

echo -e "### STARTING SIMULATIONS ###\n"

printf "sim_id\toutcome\tNeA\tNeB\ts\tr\tmu\tL\tm\tmut_pos\trise_gen\tfix_gen\tend_gen\tsamp\tmut_freq\trun_CPU_time(s)\tchg_r\tsplit_gen\tchg_gen\n" >> summary.txt
printf "sim_id\toutcome\tNeA\tNeB\ts\tr\tmu\tL\tm\tmut_pos\trise_gen\tloss_gen\tend_gen\tsamp\tmut_freq\trun_CPU_time(s)\tchg_r\tsplit_gen\tchg_gen\n" >> log.txt
printf "sim_id\tgen\tmutFreq\ts\trise_gen\tend_gen\tsplit_gen\tfail_count\tmax_fail\tseed\tinitSeed\n" >> debug.txt
echo -e "- window_size\tstep\tselection_regime" >> stats_calc_window.txt

{
read
 while IFS= read -r line; do
    id=$(echo "$line" | cut -d$'\t' -f1)
    NeMin=$(echo "$line" | cut -d$'\t' -f2)
    NeMax=$(echo "$line" | cut -d$'\t' -f3)
    r=$(echo "$line" | cut -d$'\t' -f4)
    mu=$(echo "$line" | cut -d$'\t' -f5)
    L=$(echo "$line" | cut -d$'\t' -f6)
    samp=$(echo "$line" | cut -d$'\t' -f7)
    chg_r=$(echo "$line" | cut -d$'\t' -f8)

# Bit of python to draw a random Ne and get samp >= Ne*chg_r

Ne=$(python -S -c "import random
Ne = random.randrange(${NeMin}, $((${NeMax}+1)))
print(Ne)")

samp=$(python -S -c "import math
Ne_chg = math.trunc(int(${Ne})*${chg_r})
if (${samp}>Ne_chg):
    print(Ne_chg)
else :
    print(${samp})")

# Step 1 : run SLiM simulations using prior.txt parameters

    echo -e "- SLiM simulating - sim_id ${id} -"

    while [ ! -f ./${id}_sweep_parameters.txt ]
    do
        if [ -f "./checkpoint.txt" ]; then
            echo -e "\n- DELETE PREVIOUS CHECKPOINT -"
            rm checkpoint.txt
        fi

        echo -e " - NEW SLiM INSTANCE - \n "
    slim -t -m -d sim_id=${id} -d Ne=${Ne} -d r=${r} -d mu=${mu} -d L=$((${L}-1)) -d samp=${samp} -d chg_r=${chg_r} -d debug=F  ../../../bin/CHG-SIM.slim > /dev/null
    done
    
    echo -e "- SLiM simulation ${id} done -\n"

    # update summary file
    echo -e "- updating summary file -"
    cat "${id}_sweep_parameters.txt" | tail -n 1 >> summary.txt
    echo -e "- summary file updated -\n"

    done 
} < ../param/prior.txt

echo -e "### SIMULATIONS FINISHED ###\n"

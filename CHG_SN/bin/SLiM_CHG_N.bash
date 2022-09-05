#!/usr/bin/bash

# Keywords : run neutral simulations SLiM bash constant CHG-N

# Run the CHG-N scenario pipeline
# Is part of the CHG scenario
# Run CHG_N-SIM.slim based on the contents of each id_sweep_parameters.txt files on the results/ folder

echo -e "### STARTING NEUTRAL SIMULATIONS ###\n"

printf "sim_id\toutcome\tNeA\tNeB\ts\tr\tmu\tL\tm\tmut_pos\trise_gen\tfix_gen\tend_gen\tsamp\tmut_freq\trun_CPU_time(s)\tchg_r\tsplit_gen\tchg_gen\n" >> summary.txt
printf "sim_id\toutcome\tNeA\tNeB\ts\tr\tmu\tL\tm\tmut_pos\trise_gen\tloss_gen\tend_gen\tsamp\tmut_freq\trun_CPU_time(s)\tchg_r\tsplit_gen\tchg_gen\n" >> log.txt
printf "sim_id\tgen\tmutFreq\ts\trise_gen\tend_gen\tsplit_gen\tfail_count\tmax_fail\tseed\tinitSeed\n" >> debug.txt
echo -e "- window_size, step and selection_regime : saved in stats_calc_window.txt -" >> stats_calc_window.txt


# Step 0 : Parse parameters from sweep simulations

for file in $(ls ../results/ | grep parameters.txt);do
    id=$(tail -n 1 ../results/${file} | cut -d$'\t' -f1)
    NeA=$(tail -n 1 ../results/${file} | cut -d$'\t' -f3)
    NeB=$(tail -n 1 ../results/${file} | cut -d$'\t' -f4)
    s=$(tail -n 1 ../results/${file} | cut -d$'\t' -f5)
    r=$(tail -n 1 ../results/${file} | cut -d$'\t' -f6)
    mu=$(tail -n 1 ../results/${file} | cut -d$'\t' -f7)
    L=$(tail -n 1 ../results/${file} | cut -d$'\t' -f8)
    m=$(tail -n 1 ../results/${file} | cut -d$'\t' -f9)
    mut_pos=$(tail -n 1 ../results/${file} | cut -d$'\t' -f10)
    rise_gen=$(tail -n 1 ../results/${file} | cut -d$'\t' -f11)
    fix_gen=$(tail -n 1 ../results/${file} | cut -d$'\t' -f12)
    end_gen=$(tail -n 1 ../results/${file} | cut -d$'\t' -f13)
    samp=$(tail -n 1 ../results/${file} | cut -d$'\t' -f14)
    mut_freq=$(tail -n 1 ../results/${file} | cut -d$'\t' -f15)
    chg_r=$(tail -n 1 ../results/${file} | cut -d$'\t' -f17)
    split_gen=$(tail -n 1 ../results/${file} | cut -d$'\t' -f18)
    chg_gen=$(tail -n 1 ../results/${file} | cut -d$'\t' -f19)

    # echo "id = $id - NeA = $NeA - NeB = $NeB - s = $s - r = $r - mu = $mu - L = $L - m = $m - mut_pos = $mut_pos - rise_gen = $rise_gen - fix_gen = $fix_gen - end_gen = $end_gen - samp = $samp - mut_freq = $mut_freq - chg_r = $chg_r - split_gen = $split_gen - chg_gen = $chg_gen"

# Step 1 : run SLiM simulations using id_sweep_parameters.txt

    echo -e "- SLiM simulating - NEUTRAL - sim_id ${id} -"

    while [ ! -f ./${id}_neutral_parameters.txt ]
    do
        if [ -f "./checkpoint.txt" ]; then
            echo -e "\n- DELETE PREVIOUS CHECKPOINT -"
            rm checkpoint.txt
        fi

        echo -e " - NEW SLiM INSTANCE - NEUTRAL - sim_id ${id} - \n "
    slim -t -m -d sim_id=${id} -d NeA=${NeA} -d NeB=${NeB} -d s=${s} -d r=${r} -d mu=${mu} -d L=${L} -d m=${m} -d rise_gen=${rise_gen} -d end_gen=${end_gen} -d samp=${samp} -d chg_r=${chg_r} -d split_gen=${split_gen} -d chg_gen=${chg_gen} -d debug=F  ../../../bin/CHG_N-SIM.slim > /dev/null
    done
    
    echo -e "- SLiM simulation - SWEEP - sim_id ${id} done -\n"

    # update summary file
    echo -e "- updating summary file -"
    cat "${id}_neutral_parameters.txt" | tail -n 1 >> summary.txt
    echo -e "- summary file updated -\n"

done

echo -e "### SIMULATIONS NEUTRAL FINISHED ###\n"

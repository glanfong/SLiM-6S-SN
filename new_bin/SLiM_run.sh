#!/usr/bin/env bash

# Check if prior.txt file is provided as a command-line argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <prior.txt>"
    exit 1
fi

# Get the path to the prior.txt file from the command-line argument
PRIOR_FILE="$1"


# Loop through each parameter line in the input file
while IFS=$'\t' read -r line; do
    # Skip lines starting with #
    if [[ $line == "#"* ]]; then
        continue
    fi

    # Split the line into variables using tab as the delimiter
    IFS=$'\t' read -r id Ne_anc NeA r mu L samp chg_r split_gen chg_gen mig_gen SLiM_gen m m_chg selection_coefficient <<< "$line"

    # Define output directory
    sim_id=$(echo ${id} | cut -d'-' -f1,2,3)
    OUTPUT_DIR="../simulations/${sim_id}"
    LOG_DIR="../logs/${sim_id}"

    # Create the output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"

    # Create the log directory if it doesn't exist
    mkdir -p "$LOG_DIR"

    echo "### STARTING SIMULATIONS ###"

    # Define the header for summary and log files
    SUMMARY_HEADER="sim_id\toutcome\tNeA\tNeB\ts\tr\tmu\tL\tm\tmut_pos\trise_gen\tfix_gen\tend_gen\tsamp\tmut_freq\trun_CPU_time(s)\tchg_r\tsplit_gen\tchg_gen"
    LOG_HEADER="sim_id\toutcome\tNeA\tNeB\ts\tr\tmu\tL\tm\tmut_pos\trise_gen\tloss_gen\tend_gen\tsamp\tmut_freq\trun_CPU_time(s)\tchg_r\tsplit_gen\tchg_gen"
    DEBUG_HEADER="sim_id\tgen\tmutFreq\ts\trise_gen\tend_gen\tsplit_gen\tfail_count\tmax_fail\tseed\tinitSeed"

    # Create header in the summary and log files
    # Check if the files exist before creating and writing headers
    if [ ! -f "$OUTPUT_DIR/summary.txt" ]; then
        echo -e "$SUMMARY_HEADER" > "$OUTPUT_DIR/summary.txt"
    fi

    if [ ! -f "$OUTPUT_DIR/log.txt" ]; then
        echo -e "$LOG_HEADER" > "$OUTPUT_DIR/log.txt"
    fi

    if [ ! -f "$OUTPUT_DIR/debug.txt" ]; then
        echo -e "$DEBUG_HEADER" > "$OUTPUT_DIR/debug.txt"
    fi

    if [ ! -f "$OUTPUT_DIR/stats_calc_window.txt" ]; then
        echo -e "window_size\tstep\tselection_regime" > "$OUTPUT_DIR/stats_calc_window.txt"
    fi

    # Run SLiM simulations as long as the parameters.txt output file isn't created
    while [ ! -f "$OUTPUT_DIR/${id}_sweep_parameters.txt" ]; do
        if [ -f "$OUTPUT_DIR/checkpoint.txt" ]; then
            echo -e "\n- DELETE PREVIOUS CHECKPOINT -"
            rm "$OUTPUT_DIR/checkpoint.txt"
        fi

        echo -e " - NEW SLiM INSTANCE - SWEEP - $id -"

        selection="sweep"
        slim -t -m  -d "OUTPUT_DIR='$OUTPUT_DIR'" -d "LOG_DIR='$LOG_DIR'" -d "sim_id='$id'" -d "selection_coefficient_input='$selection_coefficient'" -d "selection='$selection'" -d Ne="$Ne_anc" -d NeA="$NeA" -d NeB="$Ne_anc" -d r="$r" -d mu="$mu" -d L=$((${L} - 1)) -d samp="$samp" -d chg_r="$chg_r" -d m="$m" -d m_chg="$m_chg" -d SLiM_gen="$SLiM_gen" -d mig_gen="$mig_gen" -d chg_gen="$chg_gen" -d split_gen="$split_gen" -d debug=F ./6S_Sweep-SIM.slim


        selection="neutral"
        echo -e " - NEW SLiM INSTANCE - NEUTRAL - $id -"
        slim -t -m  -d "OUTPUT_DIR='$OUTPUT_DIR'" -d "LOG_DIR='$LOG_DIR'" -d "sim_id='$id'" -d "selection_coefficient_input='$selection_coefficient'" -d "selection='$selection'" -d Ne="$Ne_anc" -d NeA="$NeA" -d NeB="$Ne_anc" -d r="$r" -d mu="$mu" -d L=$((${L} - 1)) -d samp="$samp" -d chg_r="$chg_r" -d m="$m" -d m_chg="$m_chg" -d SLiM_gen="$SLiM_gen" -d mig_gen="$mig_gen" -d chg_gen="$chg_gen" -d split_gen="$split_gen" -d debug=F ./6S_Sweep-SIM.slim

        # touch $OUTPUT_DIR/${id}_sweep_parameters.txt
    done

    echo "- SLiM simulation - SWEEP - $id done -"

    # Update summary file
    echo "- updating summary file -"
    tail -n 1 "$OUTPUT_DIR/${id}_sweep_parameters.txt" >> "$OUTPUT_DIR/summary.txt"
    echo "- summary file updated -"
done < "$PRIOR_FILE"

echo "### SIMULATIONS SWEEP FINISHED ###"

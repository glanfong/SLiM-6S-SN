#!/usr/bin/bash

# Keywords : run simulations SLiM bash constant CHG

# Run the CHG scenario pipeline
# Has to be launched from CHG/bin

# DEFINE binpath #
CHGbinpath=$(pwd)

# Create simulation_directory - go to most recent simulation_directory/param 
PHDYEAR=1
MONTH=$(date -I | cut -d- -f2)
DAY=$(date -I | cut -d- -f3)
random_id=$(echo $(mktemp -d -t XXXX | cut -d"/" -f3))

bash ./dir_creat_CHG.bash ${random_id}
cd ../sim/CHG-$PHDYEAR$MONTH$DAY-$random_id/param

# create prior.txt based on parameters - go to results directory
# $1 = NeMin - $2 = NeMax - $3 = r - $4 = mu - $5 = L - $6 = samp - $7 = chg_r - $8 = n_rep
bash ${CHGbinpath}/prior_creat_CHG.bash ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8}
bash ${CHGbinpath}/metadata_prior_update.bash
cd ../results

# Run different steps of simulations
# 1 : SLiM forward simulations
# 2 : Recapitation & ms output
# 3 : Summary statistics & 

bash $CHGbinpath/SLiM_CHG.bash
bash $CHGbinpath/recap_CHG.bash sweep
bash $CHGbinpath/stats_calc_CHG.bash 0.02 0.01 sweep
#bash $CHGbinpath/sim2box.bash

cd ../results_Neutral

bash $CHGbinpath/SLiM_CHG_N.bash
bash $CHGbinpath/recap_CHG.bash neutral
bash $CHGbinpath/stats_calc_CHG.bash 0.02 0.01 neutral
#bash $CHGbinpath/sim2box.bash

# aplay -q ~/Musique/GBA-FE_TSS-SFX/Item.wav
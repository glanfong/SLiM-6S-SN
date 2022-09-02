#!/usr/bin/bash

# Keywords : run simulations SLiM bash constant MGD

# Run the MGD scenario pipeline
# Has to be launched from MGD/bin

# DEFINE binpath #
MGDbinpath=$(pwd)

# Create simulation_directory - go to most recent simulation_directory/param 
PHDYEAR=1
MONTH=$(date -I | cut -d- -f2)
DAY=$(date -I | cut -d- -f3)
random_id=$(echo $(mktemp -d -t XXXX | cut -d"/" -f3))

bash ./dir_creat_MGD.bash ${random_id}
cd ../sim/MGD-$PHDYEAR$MONTH$DAY-$random_id/param

# create prior.txt based on parameters - go to results directory
# $1 = NeMin - $2 = NeMax - $3 = r - $4 = mu - $5 = L - $6 = samp - $7 = chg_r - $8 = n_rep
bash ${MGDbinpath}/prior_creat_MGD.bash ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8}
bash ${MGDbinpath}/metadata_prior_update.bash
cd ../results

# Run different steps of simulations
# 1 : SLiM forward simulations
# 2 : Recapitation & ms output
# 3 : Summary statistics & 

bash $MGDbinpath/SLiM_MGD.bash
bash $MGDbinpath/recap_MGD.bash sweep
bash $MGDbinpath/stats_calc_MGD.bash 0.02 0.01 sweep
# bash $MGDbinpath/sim2box.bash

cd ../results_Neutral

bash $MGDbinpath/SLiM_MGD_N.bash
bash $MGDbinpath/recap_MGD.bash neutral
bash $MGDbinpath/stats_calc_MGD.bash 0.02 0.01 neutral
# bash $MGDbinpath/sim2box.bash

#aplay -q ~/Musique/GBA-FE_TSS-SFX/Item.wav
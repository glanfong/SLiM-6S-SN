#!/usr/bin/bash

# Keywords : run simulations SLiM bash constant CHG

# Run the CHG scenario pipeline

bash ../../../bin/SLiM_CHG.bash
bash ../../../bin//stats_calc_CHG.bash ${1:-1} ${2:-1}
# bash ../../../bin/sim2box.bash

aplay -q ~/Musique/GBA-FE_TSS-SFX/Item.wav
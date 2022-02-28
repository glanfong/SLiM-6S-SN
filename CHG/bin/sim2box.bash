#!/usr/bin/bash

# Keywords : sim2box png image picture simulations SLiM bash demographic change CHG

# Run sim2box_single_YOLOv5.py on the simulations within the current directory - produces .png files

# /!\ HAS to be launch from within "results" folder /!\ 

echo -e "### CREATING .PNG FILES ###\n"

dpi=300

for id in $(ls *_parameters.txt | cut -d'_' -f1); do
	python3 ${CHGbinpath}/sim2box_single_YOLOv5.py dpi=${dpi} datapath=$(pwd) simulation=${id} object=posSelection;
	echo "${id} corresponding .png files created."
done

echo -e "\n### .PNG FILES CREATED ###\n"
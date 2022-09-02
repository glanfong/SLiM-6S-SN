#!/bin/bash

# Keywords : prior simulations SLiM bash creat demographic change CHG

# Create or update 'prior.txt' with set parameters :

echo " /!\ - packages infos are 'hard'-coded in metadata - /!\ "
echo " /!\ - be careful to packages and version you're using and update metadata accordingly - /!\ "
# get current date for folder name

PHDYEAR=1
MONTH=$(date -I | cut -d- -f2)
DAY=$(date -I | cut -d- -f3)
# random_id=$(echo $(mktemp -d -t XXXX | cut -d"/" -f3))

# create today's sim folder

mkdir "../sim/CHG-$PHDYEAR$MONTH$DAY-$1"
binpath=$(pwd)

cd ../sim/CHG-$PHDYEAR$MONTH$DAY-$1/
mkdir param
mkdir results
mkdir results_Neutral

# create a basic 'metadata' file

touch metadata
echo -e "id\tCHG-$PHDYEAR$MONTH$DAY-$random_id" >> metadata
echo -e "author\tGLF" >> metadata
echo -e "creation_date\t$(date -I)\n" >> metadata
echo -e "# Packages #" >> metadata
echo -e "packages\tversion\nSLiM\t\tv3.7.1\npyslim\t\tv0.700\ntskit\t\tv0.4.1\nmsprime\t\tv1.1.1\npython\t\tv3.9.9\n" >> metadata
echo -e "# Scripts #" >> metadata
echo -e "$(ls $binpath | cut -d' ' -f1)\n" >> metadata
echo -e "# Keywords #" >> metadata
echo -e "SLiM simulation genomic - add more keywords!\n" >> metadata
echo -e "# Context #" >> metadata
echo -e "- add some context for the simulation -\n" >> metadata

# echo -e "# Packages Version #" >> metadata
# echo -e "# Packages Version #" >> metadata
# echo -e "# Packages Version #" >> metadata
# echo -e "# Packages Version #" >> metadata
# echo -e "# Packages Version #" >> metadata
# echo -e "# Packages Version #" >> metadata
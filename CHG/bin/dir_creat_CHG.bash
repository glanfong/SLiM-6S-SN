#!/bin/bash

# Keywords : directory simulations SLiM bash creat demographic change CHG

# Create necessary directories to run simulations

echo " /!\ - packages infos are 'hard'-coded in metadata - /!\ "
echo " /!\ - be careful to packages and version you're using and update metadata accordingly - /!\ "

# Get current date for folder name
PHDYEAR=1
MONTH=$(date -I | cut -d- -f2)
DAY=$(date -I | cut -d- -f3)
random_id=$(echo $(mktemp -d -t XXXX | cut -d"/" -f3))

# Create sim folder

mkdir "../sim/CHG-$PHDYEAR$MONTH$DAY-$random_id"
binpath=$(pwd)

# Go to sim folder

cd ../sim/CHG-$PHDYEAR$MONTH$DAY-$random_id/
mkdir param
mkdir results

# Create a basic 'metadata' file

touch metadata
echo -e "id\tCHG-$PHDYEAR$MONTH$DAY-$random_id" >> metadata
echo -e "author\tGLF" >> metadata
echo -e "creation_date\t$(date -I)\n" >> metadata
echo -e "# Packages #" >> metadata
echo -e "packages\tversion\nSLiM\t\tv3.7.1\npyslim\t\tv0.700\ntskit\t\tv0.4.1\npython\t\tv3.9.1\n" >> metadata
echo -e "# Scripts #" >> metadata
echo -e "$(ls $binpath | cut -d' ' -f1)\n" >> metadata
echo -e "# Keywords #" >> metadata
echo -e "SLiM simulation genomic - add more keywords!\n" >> metadata
echo -e "# Context #" >> metadata
echo -e "- add some context for the simulation -\n" >> metadata
#!/bin/bash
#SBATCH --cpus-per-task=1 #1 seul CPU par tache
#SBATCH --ntasks=1 # une seule tache par job
#SBATCH --time=24:00:00
#SBATCH --job-name=statCalc-SLiM-6S
#SBATCH --partition=long
#SBATCH --output=./stdout/stdout_task_%a #crée un fichier de sortie std par tache avec le No de tache (en fonction du job array)
#SBATCH --mem=4096M

# To launch this script (with batch size = 5 tasks)
# sbatch --array=0-$(ls *prior_parameters.txt | wc -l)%5 SLiM-SIM_run_array.slurm

module load python/3.9

# Path to the SLiM_run.sh script
STATCALC_RUN_SCRIPT="../../new_bin/statCalc_run.sh"

# Current folder path
CURRENT_FOLDER=$PWD

# Current "SIM FOLDER NAME"
# Example : CST-20904-16GV

SIM_FOLDER_NAME=$(basename $PWD)

# - TABLE OF TREES AND TABLE OF PARAMETERS FILES
ms_files=($(ls *.ms)) #Crée un tableau avec les fichiers .ms

# - RUN THROUGH ALL TREES FILES - #
currentFile=${ms_files[$SLURM_ARRAY_TASK_ID]} # SLURM_ARRAY_TASK_ID=> récupère l'ID de la tache courante (de 0 à nbr de fichiers prior_parameters.txt) et récupère le fichier prior_parameters.txt associé dans le tableau


echo "Task ID : $SLURM_ARRAY_TASK_ID"
echo "Recapitating file : $currentFile"

bash "$STATCALC_RUN_SCRIPT" "$PWD/$currentFile" 


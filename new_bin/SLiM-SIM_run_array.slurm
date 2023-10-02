#!/bin/bash
#SBATCH --cpus-per-task=1 #1 seul CPU par tache
#SBATCH --ntasks=1 # une seule tache par job
#SBATCH --time=24:00:00
#SBATCH --job-name=SLiM-SIM-6S_sweep
#SBATCH --partition=long
#SBATCH --output=./stdout/stdout_task_%a #crée un fichier de sortie std par tache avec le No de tache (en fonction du job array)
#SBATCH --mem=4096M

# To launch this script (with batch size = 5 tasks)
# sbatch --array=0-$(ls *prior_parameters.txt | wc -l)%5 SLiM-SIM_run_array.slurm

module unload python/3.7
module load slim/4.0.1

# Path to the SLiM_run.sh script
SLIM_RUN_SCRIPT="./SLiM_run.sh"
BIN_PATH="../../new_bin/"

# Current folder path
CURRENT_FOLDER=$PWD

prior_files=($(ls *prior_parameters.txt)) #Crée un tableau avec les fichiers prior_parameters.txt
currentFile=${prior_files[$SLURM_ARRAY_TASK_ID]} # SLURM_ARRAY_TASK_ID=> récupère l'ID de la tache courante (de 0 à nbr de fichiers prior_parameters.txt) et récupère le fichier prior_parameters.txt associé dans le tableau

echo "Task ID : $SLURM_ARRAY_TASK_ID"
echo "Processing file : $currentFile"
currentFilePath=$(echo ${CURRENT_FOLDER}/${currentFile} )
echo $currentFilePath

cd $BIN_PATH
bash "$SLIM_RUN_SCRIPT" "$currentFilePath"

cd $CURRENT_FOLDER

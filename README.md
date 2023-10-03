
# SLiM Simulations - 6S-SN
## About this repository
This repository contains the scripts, files and folders used to run both the CHG (BTL/CST/EXP) and MGD (MGB/MIG/MGX) parts of the 6S-SN-simulations with the use of the SLiM simulator and the tskit python module. The goal is to generate pseudo-genomic data under 6 different demographic scenarios (6S) with either a selective sweep occuring or not (SN). These simulations will then be used to train a CNN to differenciate between the different scenarios and to detect the selective sweeps.

## Simple Illustrative Example - 
### Step 1 - SLiM Simulations and Recapitation
#### STEP 1.1 - SLiM Simulations
For this example, we will **simulate 10 run of each scenario (BTL/CST/EXP and MGB/MIG/MGX)** and go through the **recapitation process** for those simulations.

First, to **generate the parameters** used by the SLiM script, go to the **./bin folder** and run the following python command :


```
# python generate_sim_parameters.py Ne_min Ne_max scenario dip_Nr dip_Nmu L migration samp n_rep

# Simulations without migration
python generate_sim_parameters.py 100 10000 BTL 0.02 0.02 100000 0 20 10
python generate_sim_parameters.py 100 10000 CST 0.02 0.02 100000 0 20 10
python generate_sim_parameters.py 100 10000 EXP 0.02 0.02 100000 0 20 10

# Simulation with migration
python generate_sim_parameters.py 100 10000 BTL 0.02 0.02 100000 1 20 10
python generate_sim_parameters.py 100 10000 CST 0.02 0.02 100000 1 20 10
python generate_sim_parameters.py 100 10000 EXP 0.02 0.02 100000 1 20 10

```

Each set of parameter will have a folder created inside **./parameters/** with a **unique ID** associated, indicating the **scenario**, a **timestamp** and **4 random characters** (_CST-20831-DFK8 for example_). Inside each folder, one *prior_parameters.txt file is created for each repetition (_so 20 parameters files per scenario in our example_).

<p align="left"> <b> Example </b> : ./parameters/CST-20831-DFK8/CST-20831-DFK8-0001_prior_parameters.txt </p>

```
# Lines starting with a # will be ignored
# id    Ne_anc  NeA     r       mu      L       samp    chg_r   split_gen       chg_gen mig_gen SLiM_gen        m       m_chg
CST-20831-DFK8-0001     7114    7114    1e-06   1e-06   100000  20      1.0000  20202   7263    8303    6302    0       0
```

If you're **working on a cluster**, you can **launch SLiM simulations using job arrays**. _Please do note that this will launch one separate job for each parameters subdirectory present inside the parameters/ folder._ To do so :

```
# Launch SLiM simulations up to 10 simultaneous simulations per parameters subdirectory
bash launch_SLiM_array.bash 10
```

Else, you can **launch the SLiM simulations sequentially** using :

```
# Launch SLiM simulations sequentially
bash launch_sim.sh
```
_Do note that this will launch sequential SLiM simulations, one for each parameter file, going through all the parameters present in all parameters subdirectories of the parameters/ folder._


SLiM simulations' **output files are stored in ./simulations**, in a folder named as the corresponding parameters folder. Each SLiM simulation generate **four output files**, two for the **sweep** simulations and two for the corresponding **neutral** simulations, as follow :

- <b>*_neutral_parameters.txt</b> : containing simulation paramters (sim_id, outcome, NeA, NeB, s, r, mu, L, m, mut_pos, rise_gen, fix_gen, SLiM_gen, samp, mut_freq, chg_r, split_gen, chg_gen, mig_gen, ... see Part X for more details on each parameter.)
- <b>*_neutral.trees</b> : record of true local ancestry of every chromosome position in every individual of the SLiM model.
- <b>*_sweep_parameters.txt</b> : containing simulation paramters (sim_id, outcome, NeA, NeB, s, r, mu, L, m, mut_pos, rise_gen, fix_gen, SLiM_gen, samp, mut_freq, chg_r, split_gen, chg_gen, mig_gen, ... see Part X for more details on each parameter.)
- <b>*_sweep.trees</b> : record of true local ancestry of every chromosome position in every individual of the SLiM model. 

#### STEP 1.2 - Recapitation and .ms output

Now, in order to **"recapitate" the .trees files** (*i.e add an ancestry history by running coalescent simulations and adding neutral mutations*), run the following command :

```
# Launch recapitation on up to 10 .trees files per simulation subdirectory
bash launch_recap_array.bash 10
```

Outputs files are stored in the corresponding simulation subdirectory located in ./simulations. For each .trees file, a corresponding .ms file is generated :

* <b>*_neutral.ms</b> :  .ms formatted (link to ms format) file containing the genomes of 40 sampled chromosomes (20 diploid individuals) sampled from the focal population.
* <b>*_sweep.ms</b> :  .ms formatted (link to ms format) file containing the genomes of 40 sampled chromosomes (20 diploid individuals) sampled from the focal population.

#### STEP 1.3 - Missing .ms files

In the current (1.0.4) version of the pyslim package, used for the recapitation and the output of the .ms files, an issue prevent some .trees files to be recapitated thus preventing the pipeline to create the associated .ms files.

To handle this issue in the most flexible way, we simply set aside the files (both *sweep* and *neutral*) for which recapitation could not take place :

```
# Create a noCounterpartMS folder inside each simulation subdirectory
# and set aside the files for which recapitation could not take place :
bash noCounterpartMS.bash
```

### STEP 2 - Summary statistics

Now to compute summary statistics from the .ms files, run the following command :

```
# Launch stat calculations on up to 10 .ms files per simulation subdirectory
bash launch_statCalc_array.bash 10
```
By default, this will generate windows of width = 0.01\*L, sliding along the genomes of the sampled individuals by steps of 0.005\*L.

Each of these windows is associated with a specific SNP, its relative position (between 0 and 1) is stored, and a set of summary statistics (details below) are computed inside each window.

Output files are directly stored in the same file as the .ms files :

* <b>*_neutral_positions.txt</b> : relative positions (between 0 and 1) of SNP inside the windows.
* <b>*_sweep_positions.txt</b> : relative positions (between 0 and 1) of SNP inside the windows.
* <b>*_neutral_sumStats.txt</b> : table of summary statistics computed on each of the windows along the genome. Each column correspond to one statistic computed inside one window. 
* <b>*_sweep_sumStats.txt</b> : table of summary statistics computed on each of the windows along the genome. Each column correspond to one statistic computed inside one window. 


#### STEP 2.1 - Missing sumStats and positions files

In some cases, the script used for computing the summary statistics could encounter an issue preventing some sumStats and/or positions files to be created.

To handle this issue in the most flexible way, we simply set aside the files (both *sweep* and *neutral*) for which sumStats and/or positions could not be computed :

```
# Create a noCounterpartStats folder inside each simulation subdirectory
# and set aside the files for which recapitation could not take place :
bash moveCounterpartSumStats.bash
```

### STEP 3 - Producing .jpg and bounding-boxes

#### STEP 3.1 - Range stats

In order to produce corresponding gray-scale pictures (.jpg files) of the sampled genomes (the .ms files), we first need to get a range for the different statistics :

```
SIMULATIONS_DIR="../simulations"

# Generate one range_stats.txt file for each simulation subdirectory
bash generate_range_stats.bash

# Get a list of all the range_stats.txt files
find $SIMULATIONS_DIR -name "range_stats.txt" > list_ranges.txt

# Create a 'consensus' range_stats.txt file
# (do not that this file will be created inside the current ./new_bin/ folder)
python global_ranges.py list_ranges.txt > range_stats.txt
```

Once the consensus range_stats.txt file is created, you can replace the existing range_stats.txt files inside each simulation subdirectory :

```
# Loop through each subfolder in the simulation directory
# and replace the existing range_stats.txt file by the  consensus range_stats.txt file 

for subfolder in $(ls $SIMULATIONS_DIR | grep -E 'BTL|CST|EXP|MGB|MGX|MIG'); do
    if [ -d "$subfolder" ]; then
        echo "SIMULATION FOLDER: $(basename "$subfolder")"
        cp range_stats.txt $SIMULATIONS_DIR/$subfolder/.
        echo -e "FOLDER - CONSENSUS RANGE_STATS.TXT FILE COPIED"
    fi
done
```

#### STEP 3.2 - Produce .jpg and associated bounding boxes labels

Now, in order to produce the .jpg and the associated labels used to train the CNN, run :

```
# Launch sim2box on up to 10 files per simulation subdirectory
bash launch_sim2box_array.bash 10
```

By default, this will generate .jpg files of size 500 x 500 pixels (at 300 dpi) and the corresponding labels, stored in the same file as all the other output files (the files are the same for the 'sweep' counterparts):

* <b>*_neutral_rawData.jpg</b> : picture of the sampled genomes, with ancestral/derived alleles coded as white/black cells. The first and last line are mean divergence observed between two consecutive SNP.
* <b>*_neutral_rawData.txt</b> : YOLOv5 formatted label (position) of the selective sweep (class x_center y_center width height) on the rawData .jpg file.
* <b>*_neutral_globalPic.jpg</b> : picture of the summary statistics computed on sliding windows along the sampled genomes. The gray scale is based on the range_stats.txt consensus file.
* <b>*_neutral_globalPic.txt</b> : YOLOv5 formatted label (position) of the selective sweep (class x_center y_center width height) on the globalPic .jpg file.

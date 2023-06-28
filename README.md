
# SLiM Simulations - 6S-SN
## About this repository
This repository contains the scripts, files and folders used to run both the CHG (BTL/CST/EXP) and MGD (MGB/MIG/MGX) parts of the 6S-SN-simulations with the use of the SLiM simulator and the pyslim python module. The goal is to generate genomic data under 6 different demographic scenarios (6S) with either a selective sweep occuring or not (SN). These simulations will later be used to train a CNN to differenciate between the different scenarios and to detect the selective sweeps.

## Simple Illustrative Example - 
### Step 1 - SLiM Simulations and Recapitation
For this example, we will **simulate 1 run of each CHG scenario (BTL/CST/EXP)** and go through the **creation of a dataset** from those simulations.

First, we will **run the SLiM simulations** from specified parameters.
- Go to CHG_SN/bin/
- Go to parameters/ and edit/create one parametersX.txt file per run (1 run = 1 set of parameters) ; for example, here we will use :
<p align="left"> parameters1.txt </p>

```
# Lines starting with # will be ignored
#NeMin  NeMax   r       mu      L       samp    chg_r   n_rep
100     10000   1e-6    1e-6    100000  20      1       100
```
<p align="left"> parameters2.txt </p>

```
# Lines starting with # will be ignored
#NeMin  NeMax   r       mu      L       samp    chg_r   n_rep
100     10000   1e-6    1e-6    100000  20      0.1       100
```

<p align="left"> parameters3.txt </p>

```
# Lines starting with # will be ignored
#NeMin  NeMax   r       mu      L       samp    chg_r   n_rep
100     10000   1e-6    1e-6    100000  20      10       100
```
- From the bin/ folder, run the following to launch one job for each parametersX.txt file in the parameters/ folder :

```
bash jobs_CHG.bash
```
Please, do not that runs with different scenarios will take different amount of time to reach completion. As a general rule of thumb, BTL runs are expected to be the fastest, EXP runs to be the longest and CST in-between.

You will end up with one run folder per job, each containing 3 types of files per simulation (***selection** being either **sweep** or **neutral***) :
- **xxx_*selection*.trees** : the tree-sequence data (a concise encoding of the correlated genealogies along the chromosome).
- **xxx_*selection*_parameters.txt** : parameters associated with this specific simulation (populations sizes, selective coefficient of the beneficial mutation, etc.).
- **xxx_*selection*.ms** : concise format to encode the sample genomes. Contains the number of segregated sites, their position within the genome, and the state of the allele present at the corresponding SNP (derived allele is denoted with a 1 and the ancestral type with a 0). 

### Step 2 - Compute Summary Statistics

**Note** : Please, refer to https://github.com/popgenomics/deepDILS for a more detailled run on how to compute summary statistics on the results of the previous step.

Now, we will compute summary statistics from sliding bins along the genomes. To do so :

- Clone the following repo : https://github.com/popgenomics/deepDILS on same folder as your bin/ and sim/ folders.
```
git clone https://github.com/popgenomics/deepDILS
```
-  Then, on each simulation, run the following command : 
```
python3 ../scripts/msmscalc_onePop.py infile=${iteration}_${model}.ms nIndiv=40 nCombParam=1 regionSize=100000 width=0.01 step=0.005 nRep=1 root=${iteration}_${model}
```
To streamline this process, you could use the script 'msmscalc_jobArray.slurm' (inside the bin/CHG_dataProcessing/ folder).

First, copy the script into the sim/ folder :
```
# from the sim/ folder
cp ../bin/CHG_dataProcessing/msmscalc_jobArray.slurm .
```
Then, run the script from the sim/ folder :
```
sbatch --array=0-$(ls | grep CHG- | wc -l)%24 msmscalc_jobArray.slurm
```
This will run the script and work on the run folders by batches of 24 folders at a time. 

You will end up with one run folder per job, each now containing 5 types of files per simulation (***selection** being either **sweep** or **neutral***) :
- **xxx_*selection*.trees**
- **xxx_*selection*_parameters.txt**
- **xxx_*selection*.ms**
- **xxx_*selection*_sumStats.txt** : contains a table with summary statistics computed within sliding bins along the genome.
- **xxx_*selection*_positions.txt** : contains a able withe the relative position (between 0 and 1) of each window (--> check what really are those positions).

### Step 3 - Filter simulations

Quite a few things can go wrong at some points of this pipeline. That's why, it is possible you end up with some simulation that are not usable, either because they don't have a neutral or sweep counterpart, of because the summary statistics couldn't be computed (*for a number of reasons*).
Whatever was the reason, these simulation must be discarded before trying to produce the .jpg and associated files used for the training.

You can easily do this by using the two scripts "moveNoCounterpart.slurm" and "moveNoSumStats.slurm". Copy the scripts from bin/CHG_dataProcessing/ folder into the sim/ folder :

```
cp moveNoCounterpart.slurm ../sim/
cp moveNoSumStats.slurm ../sim/
```

And just run :
```
sbatch moveNoCounterpart.slurm
sbatch moveNoSumStats.slurm
```
### Step 4 - Get stats ranges
Now, we need to go through all simulated datasets in order to get the range of variation for each stat. It can be run independently for each dataset and a consensus file created later, to be used for production of .jpg files :

```
# can then be run independently for all simulated datasets: getAllData=0  
for iteration in $(ls *.ms | cut -d "." -f1 | sed "s/_neutral//g" | sed "s/_sweep//g" | sort | uniq); do
	python3 ../scripts/sim2box_single_YOLOv5.py dpi=300 datapath=$PWD simulation=${iteration} object=posSelection theta=0 phasing=1 plotStats=0 getAllData=0 modelSim=both &
done
```
To streamline this process, you could use the script 'sim2box_rangeStats.slurm'.
Copy the script from bin/CHG_dataProcessing/ folder into the sim/ folder :

```
cp sim2box_rangeStats.slurm ../sim/
```

And just run :
```
sbatch --array=0-$(ls . | grep CHG- | wc -l)%24 sim2box_rangeStats.slurm
```
You'll end up with one file 'range_stats.txt' inside each run folder. From there, to create a consensus file.

Get a list of _range_stats.txt_ files located in different subdirectories, from the main directory:
```
find . -name "range_stats.txt" > list_ranges.txt
```
Then execute _global_ranges.py_:
```
python3 ../bin/deepDILS/scripts/global_ranges.py list_ranges.txt > range_stats_consensus.txt
```
You can then replace the _range_stats.txt_ files located in different subdirectories by the 'consensus' file produced by _global_ranges.py_ :
```
for folder in $(ls | grep CHG-);do
    cp range_stats_consensus.txt ${folder}/results/range_stats.txt
    cp range_stats_consensus.txt ${folder}/results_Neutral/range_stats.txt
done
```
### Step 5 - Produce .jpg for Network Training

Finally, we can produce our .jpg files by running : 

```
for iteration in $(ls *.ms | cut -d "." -f1 | sed "s/_neutral//g" | sed "s/_sweep//g" | sort | uniq); do
	python3 ../scripts/sim2box_single_YOLOv5.py dpi=300 datapath=$PWD simulation=${iteration} object=posSelection theta=0 phasing=1 plotStats=0 getAllData=0 modelSim=both &
done
```
To streamline this process, you could use the script 'sim2box_produce.slurm' :

Copy the script from bin/CHG_dataProcessing/ folder into the sim/ folder :

```
cp sim2box_produce.slurm ../sim/
```

And just run :
```
sbatch --array=0-$(ls . | grep CHG- | wc -l)%24 sim2box_produce.slurm
```
You'll end up with 10 files for each simulations ((***selection** being either **sweep** or **neutral***) :
- **xxx_*selection*.trees**
- **xxx_*selection*_parameters.txt**
- **xxx_*selection*.ms**
- **xxx_*selection*_sumStats.txt** 
- **xxx_*selection*_positions.txt** 
- **xxx_*selection*_globalPic.jpg** : summary statistics computed along the genome in sliding bins. Each column is a window, each row is a statistic.
- **xxx_*selection*_globalPic_matrix.txt** : summary statistics computed along the genome in sliding bins. Each column is a window, each row is a statistic. This file is a matrix of values rather than a picture, but it sould be equivalent to xxx_*selection*_globalPic.jpg.
- **xxx_*selection*_globalPic.txt** : YOLOv5 formatted **label** (*position*) of the selective sweep (`class x_center y_center width height`) on the globalPic .jpg file.
- **xxx_*selection*_rawData.jpg** : each column is a genetic position (*SNP positions from the xxx_selection_postiions.txt file*), each row is an individual. Alleles are binary-coded (*derived allele is denoted with a 1 and the ancestral type with a 0*)
- **xxx_*selection*_rawData.txt** :YOLOv5 formatted **label** (*position*) of the selective sweep (`class x_center y_center width height`) on the rawData .jpg file.

### Step 7 - Rename simulations

Small step here, to help us easily identify each simulations later on ; we'll just add the name of the run before the name of each of it's files. To do so, you can just use the 'renameSimFiles.slurm' script.
Copy the script from bin/CHG_dataProcessing/ folder into the sim/ folder :

```
cp renameSimFiles.slurm ../sim/
```

And just run :
```
sbatch renameSimFiles.slurm
```
You'll end up with all the files for each simulations renamed. For example a file named xxx_selection.trees will be renamed CHG-YMMDD-XXXX_xxx_selection.trees.

### Step 8 - Create a Dataset from the simulations

Now, we have to split the simulations into three datasets. To do so, we are using the script "createDataset.bash".

Copy the script from bin/CHG_dataProcessing/ folder into the sim/ folder :

```
cp createDataset.bash ../sim/
```

And run, from the sim/ folder :
```
trainPart=0.7
validPart=0.2
testPart=0.1
bash createDataset.bash C $trainPart $validPart $testPart $PWD

# On cluster, you can run :
 sbatch --partition XXX --wrap="bash createDataset.bash C 0.7 0.2 0.1 $PWD"
```
You will end up with a DATASET-C-YMMDD folder. The tree architecture of this folder is detailled below. Just not here that this folder can now be used to perform training of the CNN found on this repo : [link to CNN repo].

# ON EN EST LA DANS L'EXEMPLE AVEC DATASET-TEST-1k

dsdsdsdsds
ds
ds
dsd
sd
sd
sd
sd
sd
sd
sd
s
This command will first run the SLiM simulations for which a selective sweep is requiered in order for the simulation to be completed. Then, simulations using the exact same parameters but without the beneficial mutation are run. In the end, we end up with two sub-folders, one with the simulations where a selective sweep occurs and one with no beneficial mutation.

The simulations are then recapited (see SLiM - Recapitation for more details) and converted into a .ms file.

Each job will create a new folder named "CHG-YMMDD-XXXX" *(XXXX being a random character string)*, organized as follow :

  ```
  CHG_SN
  │
  └─ bin 
  │   └─ (contains scripts)
  └─ sim
      └─  SCE-YMMDD-XXXX
      │       ├── param
      │       │   └── prior.txt
      │       ├── results
      │       │    └── id_sweep.ms
      │       │    ├── id_sweep_parameters.txt
      │       │    ├── id_sweep.trees
      │       │    ├── (...)
      │       │    ├── debug.txt
      │       │    ├── log.txt
      │       │    ├── stats_calc_window.txt
      │       │    └── summary.txt
      │       ├── results_Neutral
      │       │    └── id_neutral.ms
      │       │    ├── id_neutral_parameters.txt
      │       │    ├── id_neutral_sumStats.txt
      │       │    ├── id_neutral.trees
      │       │    ├── (...)
      │       │    ├── debug.txt
      │       │    ├── log.txt
      │       │    ├── stats_calc_window.txt
      │       │    └── summary.txt
      │       └── metadata
      └─ tuto
  ```
  *With Y = PhD Year, MM = month, DD = day, XXXX = random run ID.*

## About The Project

The goal of this project is to generate pseudo-genomic data of populations experiencing (or not) a selective sweeps from a single locus (beneficial) mutation under various demographic scenarios. These data will later be used in order to train deep-learning tools (CNN - YOLOv5) to detect selective sweeps both from a compilation of summary statistics and from raw genomic data, even in presence of demographic changes during the history of the populations - which could affect the classic pattern of skewed diversity around the beneficial mutation. Another goal will be to use these pseudo-genomic data to train another network to classify genomic data into one of these scenarios.

  

### Hybrid Simulations : Tree-sequence recording and recapitation

  

[![SLiM][SLiM-shield]][SLiM-url] - Simulations are run using the evolutionary simulation framework SLiM. We first run forward-time simulations with 'tree-sequence recording' focusing on the main event of interest of our scenario (rise of a beneficial mutation, demographic event,...) *without burn-in*. As an output, an "*id.trees*" file (containing ancestry information about the population simulated) and a corresponding "*id_parameters.txt*" file (containing the corresponding parameters of the simulation) are created.

  

[![pyslim][pyslim-shield]][pyslim-url] - We then go through a process of *recapitation* using the python package pyslim (part of tskit) which, in short, takes the .trees file and uses coalescent simulation to provide a “prior history” for the initial generation of the simulation.

  

[![msprime][msprime-shield]][msprime-url] - Following that, we use another python package, msprime (also part of tskit) to add neutral mutations to the tree sequence.

  

This hybrid approach is a way of getting "the best of both worlds" because coalescent simulations, although more limited in the degree of biological realism they can attain, are much faster than the forwards simulations implemented in SLiM. Thus, by combining the main strenght of both approaches, we end up with a fast-generated, quite biologically-accurate, tree file.

  

For a more detailled look at how simulations internally run, please refer to the comments in the <ins>XXX-SIM.slim</ins> files.

  

<p align="right">(<a href="#readme-top">back to top</a>)</p>

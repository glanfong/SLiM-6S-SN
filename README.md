
# SLiM Simulations - 6S-SN
## About this repository
This repository contains the scripts, files and folders used to run both the CHG (BTL/CST/EXP) and MGD (MGB/MIG/MGX) parts of the 6S-SN-simulations with the use of the SLiM simulator and the pyslim python module. The goal is to generate genomic data under 6 different demographic scenarios (6S) with either a selective sweep occuring or not (SN). These simulations will later be used to train a CNN to differenciate between the different scenarios and to detect the selective sweeps.

## Simple Illustrative Example - Simulation of 1 run of each scenario BTL/CST/EXP and creation of a dataset
### Step 1 - SLiM Simulations and Recapitation
First, we will run the SLiM simulations from specified parameters.
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
You will end up with one run folder per job, each containing 3 types of files per simulation (***selection** being either **sweep** or **neutral***) :
- **xxx_*selection*.trees** : the tree-sequence data (a concise encoding of the correlated genealogies along the chromosome).
- **xxx_*selection*_parameters.txt** : parameters associated with this specific simulation (populations sizes, selective coefficient of the beneficial mutation, etc.).
- **xxx_*selection*.ms** : concise format to encode the sample genomes. Contains the number of segregated
sites, their position within the genome. And the haplotype information (derived allele is denoted with a 1 and the ancestral type with a 0). 

### Step 2 - Compute Summary Statistics

**Note** : Please, refer to https://github.com/popgenomics/deepDILS for a more detailled run on how to compute summary statistics on the results of the previous step.

Now, we will compute summary statistics from sliding bins along the genomes. To do so :

- Clone the following repo : https://github.com/popgenomics/deepDILS
-  On each simulation, run the following command : 
```
python3 ../scripts/msmscalc_onePop.py infile=${iteration}_${model}.ms nIndiv=40 nCombParam=1 regionSize=100000 width=0.01 step=0.005 nRep=1 root=${iteration}_${model}
```
To streamline this process, you could use the script 'msmscalc_jobArray.slurm' on each results/ and results_Neutral/ folder. To do so :
- Copy the msmscalc_jobArray.slurm script in each results/ and results_Neutral/ folder
- From the sim/ folder, run :
```
for folder in $(ls | grep CHG-);do
	cd ${folder}/results/
	sbatch --array=0-$(ls *.ms | wc -l)%24 msmscalc_multiCPU.slurm
	cd ../results_Neutral/
	sbatch --array=0-$(ls *.ms | wc -l)%24 msmscalc_multiCPU.slurm
	cd ../../
done
```
You will end up with one run folder per job, each now containing 5 types of files per simulation (***selection** being either **sweep** or **neutral***) :
- **xxx_*selection*.trees**
- **xxx_*selection*_parameters.txt**
- **xxx_*selection*.ms**
- **xxx_*selection*_sumStats.txt** : contains a table with summary statistics computed within sliding bins along the genome.
- **xxx_*selection*_positions.txt** : contains a able withe the relative position (between 0 and 1) of each window (--> check what really are those positions).

### Step 3 - Get stats ranges
First, we need to go through all simulated datasets in order to get the range of variation for each stat. It can be run independently for each dataset and a consensus file created later, to be used for production of .jpg files :

```
# can then be run independently for all simulated datasets: getAllData=0  
for iteration in $(ls *.ms | cut -d "." -f1 | sed "s/_neutral//g" | sed "s/_sweep//g" | sort | uniq); do
	python3 ../scripts/sim2box_single_YOLOv5.py dpi=300 datapath=$PWD simulation=${iteration} object=posSelection theta=0 phasing=1 plotStats=0 getAllData=0 modelSim=both &
done
```
To streamline this process, you could use the script 'sim2box_rangeStats.slurm' :
- From the sim/ folder, run :
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
python3 global_ranges.py list_ranges.txt
```
You can replace the _range_stats.txt_ files located in different subdirectories by the 'consensus' file produced by _global_ranges.py_ :
```
for folder in $(ls | grep CHG-);do
    cp list_ranges.txt ${folder}/results/range_stats.txt
    cp list_ranges.txt ${folder}/results_Neutral/range_stats.txt
done
```

### Step 4 - Filter simulations

Quite a few things can go wrong at some points of this pipeline. That's why, it is possible you end up with some simulation that are not usable, either because they don't have a neutral or sweep counterpart, of because the summary statistics couldn't be computed (*for a number of reasons*).
Whatever was the reason, these simulation must be discarded before trying to produce the .jpg and associated files used for the training.

You can easily do this by using the two scripts "moveNoCounterpart.slurm" and "moveNoSumStats.slurm". To use them, go the sim/ folder and just run :
```
sbatch moveNoCounterpart.slurm
sbatch moveNoSumStats.slurm
```


### Step 5 - Produce .jpg for Network Training
### Step 6 - Produce .jpg for Network Training
Finally, we can produce our .jpg files by running : 

```
for iteration in $(ls *.ms | cut -d "." -f1 | sed "s/_neutral//g" | sed "s/_sweep//g" | sort | uniq); do
	python3 ../scripts/sim2box_single_YOLOv5.py dpi=300 datapath=$PWD simulation=${iteration} object=posSelection theta=0 phasing=1 plotStats=0 getAllData=0 modelSim=both &
done
```
To streamline this process, you could use the script 'sim2box_produce.slurm' :
- From the sim/ folder :
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

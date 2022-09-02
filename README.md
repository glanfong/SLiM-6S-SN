<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/glanfong/repo_name">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">SLiM Simulations - 6S-SN</h3>

  <p align="center">
    This repository contains the scripts, files and folders used to run both the CHG (BTL/CST/EXP) and MGD (MGB/MIG/MGX parts of the 6S-SN-simulations with the use of the SLiM simulator and the pyslim python module. The goal is to generate genomic data under 6 different demographic scenarios (6S) with either a selective sweep occuring or not (SN). These simulations will later be used to train a CNN to differenciate between the different scenarios and to detect the selective sweeps.
    <br />
    <a href="https://github.com/glanfong/repo_name"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/glanfong/repo_name">View Demo</a>
    ·
    <a href="https://github.com/glanfong/repo_name/issues">Report Bug</a>
    ·
    <a href="https://github.com/glanfong/repo_name/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]](https://example.com)

### General informations on simulations
#### Tree-sequence recording and recapitation

Simulations are run using the evolutionary simulation framework SLiM (https://messerlab.org/slim/). We first run forward-time simulations with 'tree-sequence recording' focusing on the main event of interest of our scenario (rise of a beneficial mutation, demographic event,...) *without burn-in*. As an output, an "*id.trees*" file (containing ancestry information about the population simulated) and a corresponding "*id_parameters.txt*" file (containing the corresponding parameters of the simulation) are created.

We then go through a process of *recapitation* using pyslim (https://tskit.dev/pyslim/docs/latest/introduction.html) which, in short, takes the .trees file and uses coalescent simulation to provide a “prior history” for the initial generation of the simulation.
Following that, we use msprime (https://tskit.dev/msprime/docs/stable/intro.html) to add neutral mutations to the tree sequence.

This hybrid approach is a popular application of pyslim because coalescent algorithms, although more limited in the degree of biological realism they can attain, can be much faster than the forwards algorithms implemented in SLiM. Thus, by combining the main strenght of different approaches, we end up with a fast-generated, *quite biologically-accurate* tree file.

For a more detailled look at how simulations actually run, please refer to the comments in the <ins>XXX-SIM.slim</ins> files.

### Scenarios - CHG scenarios

We first simulate 3 different scenarios, grouped under the common general name CHG (demographic CHanGe) : a scenario with a demographic BotTLeneck (BTL), a scenario with a population of ConSTant effective size (CST) and a scenario of demographic EXPansion (EXP).

All of the CHG scenarios are run using the same *CHG-SIM.slim* core script. Thus, they share the same parameters and **it is of high importance to note that the *choice* of scenario is done *only* by tuning the value of <ins>chg_r</ins>**. Please, refer to the detailled overview of the parameters used by the simulations in the next part of the README.

#### <ins>Scenario CST - Constant Ne - chg_r = 1</ins>

In this scenario, we simulate a single population of constant effective size (Ne) over time.
Nothing especially noteworthy here. A single beneficial mutation appears at a random generation on one of the two chromosomes of a random diploid individual of the population.

The actual part of the simulation when selection happens on the beneficial mutation is simulated forward in time in SLiM. The .trees files are recapitated and neutral mutations are added afterward.

#### <ins>Scenario BTL & EXP - Bottleneck & Expansion - chg_r < 1 & chg_r > 1</ins>

In these 2 scenarios, we simulate a single population which goes through a demographic event. It's effective size went from Na to Nb (Nb < Na for BTL, Nb > Na for EXP) after the demographic event.

It should be noted that a lot of things can be tweaked here. Please, refer to the detailled overview of the parameters used by the simulations in the next part of the README.

The actual part of the simulation when the demographic change occurs can be simulated via coalescent simulations during recapitation. Thus, only the part when the selection of the beneficial mutation happens is simulated forward in time in SLiM. The .trees files are recapitated and neutral mutation are added afterward.














Here's a blank template to get started: To avoid retyping too much info. Do a search and replace with your text editor for the following: `glanfong`, `repo_name`, `twitter_handle`, `linkedin_username`, `lanfong.guillaume@gmail.com_client`, `lanfong.guillaume@gmail.com`, `SLiM-6S-SN`, `project_description`

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

* [![Next][Next.js]][Next-url]
* [![React][React.js]][React-url]
* [![Vue][Vue.js]][Vue-url]
* [![Angular][Angular.io]][Angular-url]
* [![Svelte][Svelte.dev]][Svelte-url]
* [![Laravel][Laravel.com]][Laravel-url]
* [![Bootstrap][Bootstrap.com]][Bootstrap-url]
* [![JQuery][JQuery.com]][JQuery-url]
* [![SLiM][SLiM-shield][SLiM-url]]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites

This is an example of how to list things you need to use the software and how to install them.
* npm
  ```sh
  npm install npm@latest -g
  ```

### Installation

1. Get a free API Key at [https://example.com](https://example.com)
2. Clone the repo
   ```sh
   git clone https://github.com/glanfong/repo_name.git
   ```
3. Install NPM packages
   ```sh
   npm install
   ```
4. Enter your API in `config.js`
   ```js
   const API_KEY = 'ENTER YOUR API';
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Documentation](https://example.com)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- [ ] Feature 1
- [ ] Feature 2
- [ ] Feature 3
    - [ ] Nested Feature

See the [open issues](https://github.com/glanfong/repo_name/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Your Name - [@twitter_handle](https://twitter.com/twitter_handle) - lanfong.guillaume@gmail.com@lanfong.guillaume@gmail.com_client.com

Project Link: [https://github.com/glanfong/repo_name](https://github.com/glanfong/repo_name)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* []()
* []()
* []()

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/glanfong/repo_name.svg?style=for-the-badge
[contributors-url]: https://github.com/glanfong/repo_name/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/glanfong/repo_name.svg?style=for-the-badge
[forks-url]: https://github.com/glanfong/repo_name/network/members
[stars-shield]: https://img.shields.io/github/stars/glanfong/repo_name.svg?style=for-the-badge
[stars-url]: https://github.com/glanfong/repo_name/stargazers
[issues-shield]: https://img.shields.io/github/issues/glanfong/repo_name.svg?style=for-the-badge
[issues-url]: https://github.com/glanfong/repo_name/issues
[license-shield]: https://img.shields.io/github/license/glanfong/repo_name.svg?style=for-the-badge
[license-url]: https://github.com/glanfong/repo_name/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/linkedin_username
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 
[SLiM-shield]: https://img.shields.io/badge/dynamic/xml?color=orange&label=SLiM&query=3.7&url=https%3A%2F%2Fmesserlab.org%2Fslim%2F
[SLiM-url]: https://messerlab.org/slim/
















# SLiM-6S-SN - (CHG/MGD)

This repository contains the scripts, files and folders used to run both the **CHG (BTL/CST/EXP)** and **MGD (MGB/MIG/MGX)** parts of the 6S-SN-simulations with the use of the SLiM simulator and the pyslim python module.
The goal is to generate genomic data under 6 different demographic scenarios (6S) and this repository here focus on 3 of them. In the end, these simulations will be used to train a machine-learning tool to differenciate between the different scenarios.

## Simulations

### General informations on simulations

Simulations are run using the evolutionary simulation framework SLiM (https://messerlab.org/slim/). We first run forward-time simulations with 'tree-sequence recording' focusing on the main event of interrest of our scenario (rise of a beneficial mutation, demographic event,...) *without burn-in*. As an output, an "*id.trees*" file (containing ancestry information about the population simulated) and a corresponding "*id_parameters.txt*" file (containing the corresponding parameters of the simulation) are created.

We then go through a process of *recapitation* using pyslim (https://tskit.dev/pyslim/docs/latest/introduction.html) which, in short, takes the .trees file and uses coalescent simulation to provide a “prior history” for the initial generation of the simulation.
Following that, we use msprime (https://tskit.dev/msprime/docs/stable/intro.html) to add neutral mutations to the tree sequence.

This hybrid approach is a popular application of pyslim because coalescent algorithms, although more limited in the degree of biological realism they can attain, can be much faster than the forwards algorithms implemented in SLiM. Thus, by combining the main strenght of different approaches, we end up with a fast-generated, *quite biologically-accurate* tree file.

For a more detailled look at how simulations actually run, please refer to the comments in the <ins>CHG-SIM.slim</ins> file.

___

### CHG scenarios 

Here we apply this method to 3 different scenarios, grouped under the common general name CHG (Demographic CHanGe) : a scenario with a demographic BotTLeneck (BTL), a scenario with a population of ConSTant effective size (CST) and a scenario of demographic EXPansion (EXP).

All of the CHG scenarios are run using the same *CHG-SIM.slim* core script. Thus, they share the same parameters and **it is of high importance to note that the *choice* of scenario is done *only* by tuning the value of <ins>chg_r</ins>**. Please, refer to the detailled overview of the parameters used in the next part of the README.

#### <ins>Scenario CST - Constant Ne - chg_r = 1</ins>

In this scenario, we simulate a single population of constant effective size (Ne) over time.
Nothing especially noteworthy here. A single beneficial mutation appears at a random generation on one of the two chromosomes of a random diploid individual of the population.

The actual part of the simulation when selection happens on the beneficial mutation is simulated forward in time in SLiM. The .trees files are recapitated and neutral mutations are added afterward.

#### <ins>Scenario BTL & EXP - Bottleneck & Expansion - chg_r < 1 & chg_r > 1</ins>

In these 2 scenarios, we simulate a single population which goes through a demographic event. It's effective size went from Na to Nb (Nb < Na for BTL, Nb > Na for EXP) after the demographic event.

It should be noted that a lot of things can be tweaked here. The generation at which the demographic change occurs, the generation at which the mutation appears, but also the strength of the demographic change as well as the ending generation.

Once again, the actual part of the simulation when the demographic change as well as when selection happens on the beneficial mutation is simulated forward in time in SLiM. The .trees files are recapitated and neutral mutation are added afterward.

___

### Parameters

Here's an overview of the parameters used for the CHG scenarios.

#### <ins>Parameters in *prior.txt*</ins>

First, the parameters that are set in the *prior.txt* file using the *prior_CHG.bash* helper script.

| Parameter | Type | Description |
| :---: | :---: | :---: |
| Ne_min | int | Minimum number of individual in the ancestral population |
| Ne_max | int | Maximum number of individual in the ancestral population |
| r | float | Average recombination rate for the whole chromosome |
| mu | float | Average mutation rate for the whole chromosome |
| L | int | Length of the chromosome (bp) |
| samp | int | Number of (diploid) individual sampled from the population |
| chg_r | float | Strength of demographic event - ∈ R+ |
| n_rep | int | Number of replicas run with this set of parameters |

As said previously, the choice of scenario is made by setting the value of the chg_r parameter. **We can't stress enough how important it is to set the value of the chg_r parameter correctly as it will determine the simulated scenario.** 

| Value | Scenario |
| :---: | :---: |
| < 1 | BTL |
| = 1 | CST |
| > 1 | EXP |

#### <ins>Parameters used directly within *CHG-SIM.slim*</ins>

Most of the user-defined parameters are set in the *prior.txt* file. However, a lot of parameters are handled directly within the *CHG-SIM.slim* script. For the most part, the users won't need to delve into this part but it is of high importance to make as clear as possible how each part of the simulations is done.

| Parameter | Scope | Type | Description |
| :---: | :---: | :---: | :---: |
| sim_id | Config | int | Identifier of the simulation - use an integer for later uses |
| Ne_min | Config | int | Minimum number of individual in the ancestral population |
| Ne_max | Config | int | Maximum number of individual in the ancestral population |
| r | Config | float | Average recombination rate for the whole chromosome |
| mu | Config | float | Average mutation rate for the whole chromosome |
| L | Config | int | Length of the chromosome (bp) |
| samp | Config | int | Number of (diploid) individual sampled from the population |
| chg_r | Config | float | Strength of demographic event - ∈ R+ |
| Ne | Demographic | int | Actual number of individual in the ancestral population |
| NeChg | Demographic | int | Number of individual in the population after the demographic event |
| fix_gen | Time | int | Generation of fixation of the mutation |
| chg_gen | Time | int | Generation of occurence of the demographic change |
| end_gen | Time | int | Ending generation of the simulation |
| rise_gen | Time | int | Generation of occurence of the beneficial mutation |
| s | Genetic | float | Selection coefficient - see SLiM manual for more details |
| mut_pos | Genetic | int | Position of the mutation along the chromosome |
| run_count | Conditional Sim | int | Number of run done using the current random parameters |
| fail_count | Conditional Sim | int | Number of failed run done using the current random paramters |
| tol | Conditional Sim | float | Tolerance parameter - find reference ??? |
| max_fail | Conditional Sim | int | Max number of failed runs before changing random parameters |
| :---: | :---: | :---: | :---: |
| :---: | :---: | :---: | :---: |
| :---: | :---: | :---: | :---: |
| :---: | :---: | :---: | :---: |
| :---: | :---: | :---: | :---: |

___

## Folders organization

The contents of this repository are organized as follow :

```
SLiM-6S-CHG 
│
└─ bin 
│   └─ (see 'bin folder - contents' section for details)
└─ sim
    └─  CHG-YMMDD-XXXX
    │       ├── param
    │       │   └── prior.txt
    │       ├── results
    │       │    └── id.ms
    │       │    ├── id_parameters.txt
    │       │    ├── id_positions.txt
    │       │    ├── id_recap_mut_trees.trees
    │       │    ├── id_recap.trees
    │       │    ├── id_sumStats.txt
    │       │    ├── id.trees
    │       │    ├── (...)
    │       │    ├── log.txt
    │       │    └── summary.txt
    │       └── metadata
    └─ tuto
```
___

### *bin* folder - contents

The *bin* folder contains the scripts used to run the simulations.
Here's a quick overview of each file :

| File | Script Type | Description |
| :---: | :---: | :---: |
| CHG-SIM.slim | Core | Contains the SLiM code used to run the "forward part" of the simulations |
| dir_creat_CHG.bash | Helper | Create the sub-folders used for each "batch" of simulations |
| metadata_update.bash | Helper | Update the *metadata* file once the parameters are set in the *prior.txt* file |
| msmscalc_onePop.py | Analysis | Compute diversity indexes* (see Note below) |
| prior_CHG.bash | Helper | Easily set the parameters used for the simulations in the *prior.txt* file |
| run_CHG.bash | Helper | Run the whole pipeline |
| sim2box.bash | Helper | Run *sim2box_single_YOLOv5.py* script |
| sim2box_single_YOLOv5.py | Analysis | Create .png files from diversity indexes |
| SLiM_CHG.bash | Helper | Run *CHG-SIM.slim* script using the parameters set in the *prior.txt* file |
| stats_calc_CHG.bash | Helper | Run *trees2ms_CHG.py* and *msmscalc_onePop.py* scripts |
| tajD_check.r | Analysis | Temporary file. Contains code extracts used to check the value of Tajima's D of the simulations with R |
| trees2ms_CHG.py | Core | Recapitate, add neutral mutations and create .ms files from the .trees files outputed by *CHG-SIM.slim* |
| treesTajimas_D.py | Analysis | Temporary file. Used to quickly compute TajD for all simulations from the *summary.txt* file |
| tskitTajD.bash | Helper | Run *treesTajimas_D.py* |
| --- | --- | --- |

<ins>Note</ins> : computed diversity indexes are : mean π, π standard deviation, mean Watterson's θ, mean Tajima's D, mean Achaz's Y, Pearson correlation coefficient between genomoc position and π, and p-value of this correlation).

___

## Using 6S-CHG

A few easy steps are requiered in order to use this pipeline. They're all detailed in the "tuto" file of this repository but we find it important to give at least some pointers and informations in here too.
    
### Setup folders and parameters

Start by cloning this repository (command line : *git clone https://github.com/glanfong/SLiM-6S-CHG*). Go to SLiM-6S-CHG/CHG/bin folder and run the dir_crea_CHG.bash script. This will create a new folder named CHG-YMMDD-XXXX, where YMMDD are the current date (Y = 1, 2 or 3, MM = month, DD = day) with, inside, a **metadata** file (important note : packages version are 'hardcoded' and should be edited 'by hand') and 2 folders : **param** and **results**.
The param folder is used to store the prior.txt file, which we will create in a few moments. The results folder will contains all the results of our simulations.
    
Go to the **param** folder and run the command : bash ../../../bin/prior_CHG.bash Ne_max Ne_min r mu L samp chg_r rep
This will create a *prior.txt* file containing the specified parameters. Note that you can re-run the command multiple times in order to add new parameters to your parameter file. Once you are done, please remember to run : bash ../../../bin/metadata_update.bash to update the *metadata* file with your parameters.
    
### Running the simulations

Once you've setup your parameters, just go to the **results** folder and run bash ../../../bin/run_CHG.bash
Simulations should start and some basic information about them will be displayed on your console. Once the simulations are finished and depending on how you *run_CHG.bash* has been tweaked, you should have an output close to the one displayed on the next section.

___

## Pipeline output

For now (03-03-2022), once you've run the pipeline, your folders should looks something like the results below :

```
SLiM-6S-CHG 
│
└─ bin
│   ├── CHG-SIM.slim
│   ├── dir_creat_CHG.bash
│   ├── metadata_update.bash
│   ├── msmscalc_onePop.py
│   ├── prior_CHG.bash
│   ├── run_CHG.bash
│   ├── sim2box.bash
│   ├── sim2box_single_YOLOv5.py
│   ├── SLiM_CHG.bash
│   ├── stats_calc_CHG.bash
│   ├── tajD_check.r
│   ├── trees2ms_CHG.py
│   ├── treesTajimas_D.py
│   └── tskitTajD.bash
│   
└─ sim
    └─  CHG-YMMDD-XXXX
    │       ├── id.ms
    │       ├── id_parameters.txt
    │       ├── id_positions.txt
    │       ├── id_recap_mut_trees.trees
    │       ├── id_recap.trees
    │       ├── id_sumStats.txt
    │       ├── id.trees
    │       ├── (...)
    │       ├── log.txt
    │       └── summary.txt
    └─ tuto
```

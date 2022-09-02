#!/bin/bash

# To chose which scenario to use in your dataset use either :
# bash xxx.bash C = only CHG scenarios
# bash xxx.bash M = only MGD scenarios
# bash xxx.bash G = both CHG and MGD scenarios


### CHANGE THIS PART TO CHANGE THE CORRESPONDING QUANTITIES OF EACH DATASET

trainPart=0.7
validPart=0.2
testPart=0.1

###

PHDYEAR=1
MONTH=$(date -I | cut -d- -f2)
DAY=$(date -I | cut -d- -f3)
mkdir "./DATASET-$1-$PHDYEAR$MONTH$DAY"
cd "./DATASET-$1-$PHDYEAR$MONTH$DAY"
destination=$(pwd)

## rawData dir

mkdir rawData

cd rawData
mkdir 'train'
mkdir 'test'
mkdir 'valid'

touch data.yaml
echo -e "train: ../DATASET-$1-$PHDYEAR$MONTH$DAY/rawData/train/images" >> data.yaml
echo -e "val: ../DATASET-$1-$PHDYEAR$MONTH$DAY/rawData/valid/images\n" >> data.yaml
echo -e "nc: 2" >> data.yaml
echo -e "names: ['neutral', 'sweep']" >> data.yaml

cd train
mkdir images
mkdir labels
cd ..

cd 'test'
mkdir images
mkdir labels
cd ..

cd valid
mkdir images
mkdir labels
cd ..

cd ..

# globalPic dir

mkdir globalPic

cd globalPic
mkdir 'train'
mkdir 'test'
mkdir 'valid'

touch data.yaml
echo -e "train: ../DATASET-$1-$PHDYEAR$MONTH$DAY/globalPic/train/images" >> data.yaml
echo -e "val: ../DATASET-$1-$PHDYEAR$MONTH$DAY/globalPic/valid/images\n" >> data.yaml
echo -e "nc: 2" >> data.yaml
echo -e "names: ['neutral', 'sweep']" >> data.yaml

cd train
mkdir images
mkdir labels
cd ..

cd 'test'
mkdir images
mkdir labels
cd ..

cd valid
mkdir images
mkdir labels
cd ..

cd ../..

# copy sweep simulation

cd sampledSim

for subfolder in $(ls);do
    nbSim=$(ls $subfolder/results/| grep .png | cut -f1 -d_ | uniq | wc -l)

# copy train sim - rawData
nbTrainSim=$(python -S -c "nbTrainSim = round($nbSim*$trainPart)
print(nbTrainSim)")
    echo "$subfolder - nbTrainSim $nbTrainSim"
    for simID in $(ls $subfolder/results/| grep .png | cut -f1 -d_ | uniq | head -n $nbTrainSim);do
        echo "Copy ${simID}_rawData.png as ${subfolder}_${simID}_rawData.png"
        cp $subfolder/results/${simID}_rawData.png $destination/rawData/train/images/${subfolder}_sweep_${simID}_rawData.png
        cp $subfolder/results/${simID}_train_rawData.txt $destination/rawData/train/labels/${subfolder}_sweep_${simID}_rawData.txt 
        cp $subfolder/results/${simID}_globalPic.png $destination/globalPic/train/images/${subfolder}_sweep_${simID}_globalPic.png
        cp $subfolder/results/${simID}_train_globalPic.txt $destination/globalPic/train/labels/${subfolder}_sweep_${simID}_globalPic.txt 
    done

        # copy valid sim - rawData
nbValidSim=$(python -S -c "nbValidSim = round($nbSim*$validPart)
print (nbValidSim)")
echo "$subfolder - nbValidSim $nbValidSim"

headValidSim=$(python -S -c "headValidSim = $nbTrainSim + $nbValidSim
print (headValidSim)")
echo "$subfolder - headValidSim $headValidSim"

        for simID in $(ls $subfolder/results/| grep .png | cut -f1 -d_ | uniq | head -n $nbValidSim);do
            cp $subfolder/results/${simID}_rawData.png $destination/rawData/valid/images/${subfolder}_sweep_${simID}_rawData.png
            cp $subfolder/results/${simID}_train_rawData.txt $destination/rawData/valid/labels/${subfolder}_sweep_${simID}_rawData.txt 
            cp $subfolder/results/${simID}_globalPic.png $destination/globalPic/valid/images/${subfolder}_sweep_${simID}_globalPic.png
            cp $subfolder/results/${simID}_train_globalPic.txt $destination/globalPic/valid/labels/${subfolder}_sweep_${simID}_globalPic.txt 
        done

        # copy test sim - rawData
nbTestSim=$(python -S -c "nbTestSim = round($nbSim*$testPart)
print(nbTestSim)")
echo "$subfolder - nbTestSim $nbTestSim"

        for simID in $(ls $subfolder/results/| grep .png | cut -f1 -d_ | uniq | tail -n $nbTestSim);do
            cp $subfolder/results/${simID}_rawData.png $destination/rawData/test/images/${subfolder}_sweep_${simID}_rawData.png
            cp $subfolder/results/${simID}_train_rawData.txt $destination/rawData/test/labels/${subfolder}_sweep_${simID}_rawData.txt 
            cp $subfolder/results/${simID}_globalPic.png $destination/globalPic/test/images/${subfolder}_sweep_${simID}_globalPic.png
            cp $subfolder/results/${simID}_train_globalPic.txt $destination/globalPic/test/labels/${subfolder}_sweep_${simID}_globalPic.txt 
        done
    done
cd ..
# copy neutral simulation

cd sampledSim

for subfolder in $(ls);do
    nbSim=$(ls $subfolder/results_Neutral/| grep .png | cut -f1 -d_ | uniq | wc -l)

# copy train sim - rawData
nbTrainSim=$(python -S -c "nbTrainSim = round($nbSim*$trainPart)
print(nbTrainSim)")
    echo "$subfolder - nbTrainSim $nbTrainSim"
    for simID in $(ls $subfolder/results_Neutral/| grep .png | cut -f1 -d_ | uniq | head -n $nbTrainSim);do
        echo "Copy ${simID}_rawData.png as ${subfolder}_${simID}_rawData.png"
        cp $subfolder/results_Neutral/${simID}_rawData.png $destination/rawData/train/images/${subfolder}_neutral_${simID}_rawData.png
        cp $subfolder/results_Neutral/${simID}_train_rawData.txt $destination/rawData/train/labels/${subfolder}_neutral_${simID}_rawData.txt 
        cp $subfolder/results_Neutral/${simID}_globalPic.png $destination/globalPic/train/images/${subfolder}_neutral_${simID}_globalPic.png
        cp $subfolder/results_Neutral/${simID}_train_globalPic.txt $destination/globalPic/train/labels/${subfolder}_neutral_${simID}_globalPic.txt 
    done

        # copy valid sim - rawData
nbValidSim=$(python -S -c "nbValidSim = round($nbSim*$validPart)
print (nbValidSim)")
echo "$subfolder - nbValidSim $nbValidSim"

headValidSim=$(python -S -c "headValidSim = $nbTrainSim + $nbValidSim
print (headValidSim)")
echo "$subfolder - headValidSim $headValidSim"

        for simID in $(ls $subfolder/results_Neutral/| grep .png | cut -f1 -d_ | uniq | head -n $nbValidSim);do
            cp $subfolder/results_Neutral/${simID}_rawData.png $destination/rawData/valid/images/${subfolder}_neutral_${simID}_rawData.png
            cp $subfolder/results_Neutral/${simID}_train_rawData.txt $destination/rawData/valid/labels/${subfolder}_neutral_${simID}_rawData.txt 
            cp $subfolder/results_Neutral/${simID}_globalPic.png $destination/globalPic/valid/images/${subfolder}_neutral_${simID}_globalPic.png
            cp $subfolder/results_Neutral/${simID}_train_globalPic.txt $destination/globalPic/valid/labels/${subfolder}_neutral_${simID}_globalPic.txt 
        done

        # copy test sim - rawData
nbTestSim=$(python -S -c "nbTestSim = round($nbSim*$testPart)
print(nbTestSim)")
echo "$subfolder - nbTestSim $nbTestSim"

        for simID in $(ls $subfolder/results_Neutral/| grep .png | cut -f1 -d_ | uniq | tail -n $nbTestSim);do
            cp $subfolder/results_Neutral/${simID}_rawData.png $destination/rawData/test/images/${subfolder}_neutral_${simID}_rawData.png
            cp $subfolder/results_Neutral/${simID}_train_rawData.txt $destination/rawData/test/labels/${subfolder}_neutral_${simID}_rawData.txt 
            cp $subfolder/results_Neutral/${simID}_globalPic.png $destination/globalPic/test/images/${subfolder}_neutral_${simID}_globalPic.png
            cp $subfolder/results_Neutral/${simID}_train_globalPic.txt $destination/globalPic/test/labels/${subfolder}_neutral_${simID}_globalPic.txt 
        done
    done
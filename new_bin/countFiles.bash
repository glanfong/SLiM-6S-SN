#!/usr/bin/env bash

# À lancer depuis le dossier contenant les .trees files

SIMULATIONS_DIR="../simulations"

for subfolder in $(ls $SIMULATIONS_DIR | grep -E 'BTL|CST|EXP|MGB|MGX|MIG'); do

    # Get number of neutral and sweep *.trees files

    nbNeutralTrees=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep neutral.trees -c)
    nbSweepTrees=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep sweep.trees -c)

    # Get number of neutral and sweep *.ms files

    nbNeutralMs=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep neutral.ms -c)
    nbSweepMs=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep sweep.ms -c)

    # Get number of neutral and sweep *_parameters.txt files

    nbNeutralParam=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep neutral_parameters.txt -c)
    nbSweepParam=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep sweep_parameters.txt -c)

    # Get number of neutral and sweep *_positions.txt files

    nbNeutralPositions=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep neutral_positions.txt -c)
    nbSweepPositions=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep sweep_positions.txt -c)

    # Get number of neutral and sweep *_sumStats.txt files

    nbNeutralSumStats=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep neutral_sumStats.txt -c)
    nbSweepSumStats=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep sweep_sumStats.txt -c)

    # Get number of neutral and sweep *_globalPic.txt files

    nbNeutralGlobalPicTxt=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep neutral_globalPic.txt -c)
    nbSweepGlobalPicTxt=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep sweep_globalPic.txt -c)

    # Get number of neutral and sweep *_globalPic_matrix.txt files

    nbNeutralGlobalPicMatrix=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep neutral_globalPic_matrix.txt -c)
    nbSweepGlobalPicMatrix=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep sweep_globalPic_matrix.txt -c)

    # Get number of neutral and sweep *_globalPic.jpg files

    nbNeutralGlobalPicJpg=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep neutral_globalPic.jpg -c)
    nbSweepGlobalPicJpg=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep sweep_globalPic.jpg -c)

    # Get number of neutral and sweep *_rawData.txt files

    nbNeutralRawDataTxt=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep neutral_rawData.txt -c)
    nbSweepRawDataTxt=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep sweep_rawData.txt -c)

    # Get number of neutral and sweep *_rawData.jpg files

    nbNeutralRawDataTxt=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep neutral_rawData.jpg -c)
    nbSweepRawDataTxt=$(ls ${SIMULATIONS_DIR}/${subfolder} | grep sweep_rawData.jpg -c)

    echo -e "\n- SIMULATION FOLDER: $(basename "$subfolder") -" >> pipelineFileCount.txt
    echo -e "FILE_TYPE\tSWEEP\tNEUTRAL" >> pipelineFileCount.txt
    echo -e ".trees\t$nbSweepTrees\t$nbNeutralTrees" >> pipelineFileCount.txt
    echo -e ".ms\t$nbSweepMs\t$nbNeutralMs" >> pipelineFileCount.txt
    echo -e "param\t$nbSweepParam\t$nbNeutralParam" >> pipelineFileCount.txt
    echo -e "positions\t$nbSweepPositions\t$nbNeutralPositions" >> pipelineFileCount.txt
    echo -e "sumStats\t$nbSweepSumStats\t$nbNeutralSumStats" >> pipelineFileCount.txt
    echo -e "globalPic.txt\t$nbSweepGlobalPicTxt\t$nbNeutralGlobalPicTxt" >> pipelineFileCount.txt
    echo -e "globalPicMatrix.txt\t$nbSweepGlobalPicMatrix\t$nbNeutralGlobalPicMatrix" >> pipelineFileCount.txt
    echo -e "globalPic.jpg\t$nbSweepGlobalPicJpg\t$nbNeutralGlobalPicJpg" >> pipelineFileCount.txt
    echo -e "rawData.txt\t$nbSweepRawDataTxt\t$nbNeutralRawDataTxt" >> pipelineFileCount.txt
    echo -e "rawData.jpg\t$nbSweepRawDataTxt\t$nbNeutralRawDataTxt" >> pipelineFileCount.txt

done

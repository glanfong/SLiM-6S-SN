simulations_path=$PWD
firstArg=$1

# echo $firstArg

for subdirectory in $(ls $simulations_path | grep -E 'BTL|CST|EXP|MIG|MGB|MGX'); do
    simBasename=$(basename $subdirectory)
    simList=($(ls ${simulations_path}/${subdirectory} | grep ${simBasename} | cut -d'_' -f1 | uniq))
    
    # echo "${simList[@]}"
    
    nbSim=${#simList[@]}
    splitDirNbSim=$firstArg
    nbSplitDir=$((($nbSim + $splitDirNbSim - 1) / $splitDirNbSim)) # Calculate the number of iterations needed

    for ((i = 1; i <= nbSplitDir; i++)); do
        startSimIdx=$((1 + (i-1)*$splitDirNbSim))
        lastSimIdx=$((i*$splitDirNbSim))

        mkdir ${simBasename}_${startSimIdx}_${lastSimIdx}

        for ((j = startSimIdx - 1; j < lastSimIdx && j < nbSim; j++)); do
            simToMove="${simList[j]}"
            mv ${subdirectory}/${simToMove}* ${simBasename}_${startSimIdx}_${lastSimIdx}/
        done
    done
done


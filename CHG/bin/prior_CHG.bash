#!/bin/bash

# Keywords : prior simulations SLiM bash creat demographic change CHG

# Create or update 'prior.txt' with set parameters :
# $1 = Ne_min - $2 = Ne_max - $3 = r - $4 = mu - $5 = L - $6 = samp - $7 = chg_r - $8 = n_rep

id=99

FILE=prior.txt
if [ -f "$FILE" ]; then
    echo "- Updating $FILE -"

    id=$(tail -n 1 $FILE | cut -d$'\t' -f1)
    
    for i in $(eval echo "{${id}..$((${id}-1+${8}))}"); do
        id=$((id+=1))
        echo -e "${id}\t${1}\t${2}\t${3}\t${4}\t${5}\t${6}\t${7}" >> prior.txt
    done
    
    echo -e "- New parameters added to $FILE - "

else
    echo -e "- Creating $FILE -"
    echo -e "id\tNe_min\tNe_max\tr\tmu\tL\tsamp\tchg_r" > prior.txt

    for i in $(eval echo "{99..$((99-1+${8}))}"); do
        id=$((id+=1))
        echo -e "${id}\t${1}\t${2}\t${3}\t${4}\t${5}\t${6}\t${7}" >> prior.txt
    done

    echo -e "- New parameters added to $FILE - "
fi

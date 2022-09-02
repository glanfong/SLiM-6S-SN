#!/bin/bash

# Keywords : prior simulations SLiM bash creat demographic change MGD metadata
# update metadata file with prior parameters infos

cd ..
sed -i '/Parameters/Q' metadata
echo -e "# Parameters #" >> metadata
cat ./param/prior.txt | cut -f2- | uniq -c >> metadata
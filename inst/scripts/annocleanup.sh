#!/bin/bash

while getopts d:i:g: option
do
case "${option}"
in
d) dat=${OPTARG};;
i) gcsIngest=${OPTARG};;
g) gcsAnno=${OPTARG};;
esac
done

#Testing:
#This should be set outside the script
# cd ~/projects/whitestork/results/stpp_models/huj_eobs
# dat=data/obsbg_lbg_amt.csv
# geeDatName=huj_eobs_lbg_amt #name of the dataset on GEE. should default to dat, unless otherwise passed in
# gcsIngest=gs://mol-playground/benc/ingest_ee/$geeDatName
# gcsAnno=gs://mol-playground/benc/annotated/$geeDatName

datPath=${dat%/*} #get the path if it exists.

#Unfortunately, if no path, will return the file name
if [ "$dat" == "$datPath" ]; then
  dlP=raw
else
  dlP=$datPath/raw
fi

echo 'Removing files staged for import into GEE.'

#TODO: could check if there is anything and then delete if there is
#gsutil ls $gcsIngest
gsutil rm -r $gcsIngest #remove files staged on GCS for import into GEE.

echo 'Removing raw files exported from GEE to GCS.'

#gsutil ls $gcsAnno
gsutil -m rm -r $gcsAnno

#rm -r $dsn #remove shapefile. switch to csv upload, no longer required
#rm ${datAnnoPF%.*}.bak #remove backup file #maybe don't require this?

#
echo 'Removing raw files downloaded from GEE.'

#ls $dlP
rm -r $dlP #remove raw files

echo 'Removing backup file created prior to join.'
rm ${dat%.*}_anno.bak

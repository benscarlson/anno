#!/bin/bash

while getopts d:g: option
do
case "${option}"
in
d) dat=${OPTARG};;
g) gcs=${OPTARG};;
esac
done

# Script processes raw data output from gee into a dataframe,
# then joins to an existing dataset based on anno_id

#Paramter dat:
# The name of the un-annotated csv file. Can be:
# 1) file name only: obsbg_lbg_amt_anno.csv
# 2) file name with relative path: data/obsbg_lbg_amt_anno.csv
# 3) file name with absolute path: /Users/user/data/obsbg_lbg_amt_anno.csv
#Parameter gcs:
# Path to gcs folder that holds the raw annotated data

#Makes a folder called 'raw' that is used to download the data

#TODO: need to take these variables from command line.

#Testing:
#This should be set outside the script
#cd ~/projects/whitestork/results/stpp_models/huj_eobs
#dat=obsbg_lbg_amt.csv
#dat=data/obsbg_lbg_amt.csv
#dat=/Users/user/data/obsbg_lbg_amt.csv
#gcs=gs://mol-playground/benc/annotated/huj_eobs_lbg_amt

anno=$R_HOME/library/anno/scripts

datPath=${dat%/*} #get the path if it exists.
datFile=${dat##*/} #get the file name
datAnno=${dat%.*}_anno.csv

#Unfortunately, if no path, will return the file name
if [ "$dat" == "$datPath" ]; then
  dlP=raw
else
  dlP=$datPath/raw
fi

echo "Downloading annotated data from $gcs from to $dlP"

mkdir -p $dlP

#gsutil ls $gcs #have a look at what is in there
gsutil -m cp $gcs/* $dlP

#Process the raw results and join to the *_anno.csv file
# Note this is saving over the existing file

cp $datAnno ${datAnno%.*}.bak

#This script processes the downloaded data, then join it to the
# *_anno.csv file that was created based on the unannotated file.
#TODO: use shebang on script so I don't need to call Rscript
Rscript $anno/processGEEraw.r $datAnno --rawP $dlP

echo "Performing basic checks on processed data."
echo "Should be the same number of rows:"
nline1=$(cat $dat | wc -l)
nline2=$(cat $datAnno | wc -l)
echo $nline1
echo $nline2

#Not working for some reason
# if [$nline1 -ne $nline2]; then
#   echo 'Number of rows is not equal!'
# else
#   echo 'Number of rows is equal'
# fi

echo "Number of columns should differ by the number of annotated variables:"
head -1 ${datAnno%.*}.bak | sed 's/[^,]//g' | wc -c
head -1 $datAnno | sed 's/[^,]//g' | wc -c

echo "Column names are:"
head -1 $datAnno

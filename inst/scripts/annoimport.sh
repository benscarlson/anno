#!/bin/bash

# Script transfers data file to GCS then imports into GEE

while getopts d:g:a: option
do
case "${option}"
in
d) dat=${OPTARG};;
g) gcs=${OPTARG};;
a) asset=${OPTARG};;
esac
done

# @paramter d: (dat) The name of the un-annotated csv file. Can be:
#   1) file name only: obs.csv
#   2) file name with relative path: data/obs.csv
#   3) file name with absolute path: /Users/user/data/obs.csv
# @parameter g: (gcs) Cloud storage folder
# @parameter a: (asset) Asset name in gee TODO: make this optional, default to file name

#For testing:
# cd ~/scratch
# dat=obs.csv
# #dat=data/obs.csv
# #dat=/Users/user/data/obs.csv
# gcs=gs://mol-playground/benc/annotated/test
# asset=users/benscarlson/annotate/tracks/test_obs_anno

anno=$R_HOME/library/anno/scripts

datFile=${dat##*/} #get the file name, no path info. e.g. obs.csv
datForee=${dat%.*}_foree.csv #file with foree appended e.g. data/obs_foree.csv
datFileForee=${datFile%.*}_foree.csv #get the file name. e.g. obs.csv

gcsPF=$gcs/$datFileForee

#---- Upload file to GCS
gsutil -m cp -r $datForee $gcsPF

#---- Import file into GEE
# Default "experimental cloud api" doesn't work for csv, so need to set --no-use_cloud_api
earthengine --no-use_cloud_api upload table $gcsPF --asset_id $asset --x_column lon --y_column lat

echo Script Complete

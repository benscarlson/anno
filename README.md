Example use

````bash
datName=mydat

cd analysis

dat=data/mydat.csv
gcsimport=gs://mol-playground/benc/ingest_ee/$datName
gcsanno=gs://mol-playground/benc/annotated/$datName
asset=users/benscarlson/annotate/tracks/$datName

annoprep $dat
annoimport -d $dat -g $gcsimport -a $asset
#annotate in playground: annotate/annotate_by_static_or_ts.js
annoprocess -d $dat -g $gcsanno
annocleanup -d $dat -i $gcsimport -g $gcsanno
````
### workflow

* Each command accepts the same data set name as input (e.g. mydat.csv). However, the commands parse this name and often build different input/output file names.
* annoimport 

### annoprep 

* adds anno_id to the dataset
* subsets fields to just those that should be uploaded to gee
* saves file as <dat>_forgee.csv (can now import csv to gee)
  
### annoimport

* uploads file to gcs
* imports from gcs to gee

### Other notes

* Uploaded dataset should have anno_id that is a unique index for each feature
* Annotated environmental value should have column name env_val

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

Other notes
* Uploaded dataset should have anno_id that is a unique index for each feature
* Annotated environmental value should have column name env_val

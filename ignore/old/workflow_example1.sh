geeDatName=loburg_sum14_test
datPF=loburg_sum14_test.csv
anno=/Library/Frameworks/R.framework/Versions/3.5/Resources/library/anno/scripts
gcsPath=gs://annotate/export_to_ee/$geeDatName #GCS location to put the data on GCS for ingestion
geeAssetPF=users/benscarlson/annotate/tracks/$geeDatName
gcsExportP=gs://annotate/$geeDatName #this is where GEE puts raw, annotated files
datAnnoPF=${datPF%.*}_anno.csv #e.g. obsbg.csv -> obsbg_anno.csv #name of annotated dataset

cd ~/scratch/loburg_sum14_test

Rscript $anno/prepForGEE.r $datPF

#--build the shapefile name. dsn/shape default to datPF file name
dsn=${datPF%.*} #name of file, including path info, without extension. This is the shape dsn.
layer=${dsn##*/}.shp #gets rid of all path info, then adds file extension. This is layer name.
shp=$dsn/$layer

gsutil cp -r $dsn $gcsPath #copy data up to GCP

earthengine upload table $gcsPath/$layer --asset_id $geeAssetPF #import data into gee

#--- run annotate in gee ---#

#--- download and process raw data ---#
mkdir -p raw

gsutil -m cp $gcsExportP/* raw

Rscript $anno/processGEEraw.r $datAnnoPF

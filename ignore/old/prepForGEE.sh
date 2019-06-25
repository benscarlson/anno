#---- parameters to be passed in ----#
geeDatName=loburg_jun14
#dat=loburg_jun14.csv
dat=data/obs.csv

#-- other settings. put in settings file?
anno=/Library/Frameworks/R.framework/Versions/3.5/Resources/library/anno/scripts #TODO: !!Need to get this programatically!!
gcsPath=gs://mol-playground/benc/ingest_ee/$geeDatName #make option to pass in, else this is default
geeAsset=users/benscarlson/annotate/tracks/$geeDatName #make option to pass in, else this is default

#-- derived variables
dsn=${dat%.*}
fn=${dat##*/} #gets the file name
shp=${fn%.*}.shp #strips off file extenstion. useful for getting dsn

#manually change names so they are not shortened. Need a better way
sed -i ".bak" "1s/individual\_id/indid/" $dat; head -1 $dat
sed -i ".bak" "1s/niche\_name/name/" $dat; head -1 $dat

Rscript $anno/prepForGEE.r $dat --ptsPerGrp 200000 --extFields obs,indid,name

#Change names back and remove .bak file
sed -i ".bak" "1s/indid/individual\_id/" $dat; head -1 $dat
sed -i ".bak" "1s/name/niche\_name/" $dat; head -1 $dat
rm ${dat}.bak

#--- upload to gee
echo "Uploading dataset $geeDatName to $gcsPath"
#gsutil -m cp -r $dsn/$shp $gcsPath
gsutil -m cp -r $dsn $gcsPath

# echo "Deleting asset in GEE if it already exists"
# echo "This will return an error if the asset does not already exist."
# #TODO: check if dataset already exists before doing rm, since error message is confusing
# earthengine rm $geeAssetPF

echo "Starting GEE import task"
# dsn can be a full path, but just the folder containing the shapefile is uploaded
#   so, need to just take the folder name, add to gcsPath, and then add on the shapefile name
earthengine upload table $gcsPath/$shp --asset_id $geeAsset
##### end uploadToGee.sh

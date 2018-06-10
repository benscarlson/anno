

# datname_anno/
#   datName_original.csv the original data
#   raw/ contains raw results from gee
#   shp/datName where the shapefile is written to

prepForGEE <- function(dat,datName,ptsPerGrpReq=NULL,extraFields=NULL) {

  # if(FALSE) {
  #   datName='test_beu';
  #   ptsPerGrpReq=20;
  #   extraFields=c('obs','short_name')
  #   .annoP <- '/Users/benc/projects/annorun/data'
  #   dat <- read_csv(file.path(.annoP,'test_beu.csv'))
  # }

  #User picks a directory to run this script from
  #Temporary scaffolding code
  # if(interactive()) {
  #
  # } else {
  #   .annoP <- getwd()
  # }

  scratchP <- glue('anno_{datName}') #path of temporary files used in annotation
  shapeP <- file.path('shp',datName) #path of shapefile
  datCopyFN <- glue('{datName}_original.csv') #file name for copy of original file

  defaultFields <- c('anno_id','lon','lat','timestamp')
  uploadFields <- c(defaultFields,extraFields)

  #anno_id is a temporary, ephmeral id that is added to a dataset during the annotation process
  # this is is used to match records from the original file to annotated records
  dat <- dat %>% mutate(anno_id=row_number())

  #save the original dataset, this will have the annotated data joined to it once annotation is complete
  dir.create(scratchP,recursive=TRUE,showWarnings=FALSE) #create the temporary folder
  write_csv(dat, file.path(scratchP,datCopyFN))

  #----
  #---- Add group number ----
  #----

  #so that annotation can be broken up into groups
  #TODO: make this zero based, easier for for() loop in ee?
  if(!is.null(ptsPerGrpReq)) {
    numGrps <- floor(nrow(dat)/ptsPerGrpReq)
    ptsPerGrp <- ceiling(nrow(dat)/numGrps)
    anno_grp <- rep(1:numGrps,each=ptsPerGrp)[1:nrow(dat)]

    dat$anno_grp <- anno_grp
    uploadFields <- c('anno_grp',uploadFields)
    message(glue('Number of groups is {numGrps}'))
  }

  #----
  #---- Prep the dataset for GEE ----#
  #----

  #--- filter fields to just required fields, plus any extra fields specified in function call.
  dat <- dat %>% select_(.dots=uploadFields)

  #convert datetimes to strings that are parseable by GEE.
  message('Converting timestamps, assuming they are GMT time zone')
  dat$timestamp <- strftime(dat$timestamp, format="%Y-%m-%dT%H:%M:%SZ",tz='GMT') #make sure to specify GMT!!

  #----
  #---- Save as shapefile ----#
  #----

  #dfTracksToShape(dat=dat,dsn=,layer=)

  message('Assuming points are geographic WGS84 coordinates')
  trsp <- as.data.frame(dat)
  coordinates(trsp) <- ~lon+lat
  proj4string(trsp) <- CRS('+proj=longlat +datum=WGS84')

  #note here that point_index is saved as a floating point instead of an integer
  #this is because r doesn't seem to support large integers (such as long or int64)
  message('Writing shapefile...')
  dir.create(file.path(scratchP,shapeP),recursive=TRUE,showWarnings=FALSE)
  writeOGR(obj=trsp, dsn=file.path(scratchP,shapeP), layer=datName, driver="ESRI Shapefile", overwrite_layer = TRUE)

  message(glue('Shapefile written to {file.path(scratchP,shapeP)}'))
}



#' Preps dataset for annotation in GEE.
#' 1) Saves a copy of the data, but with anno_id added as a column.
#' 2) Saves a shapefile formatted for upload to GEE.
#'
#' @param dat Dataset
#' @param datAnnoIdPF Path and Filename specifying where to save original dataset, with anno_id added.
#' @param geeShapefileP Path of output shapefile, prepped for GEE. Final folder will be the name of the shapefile.
#' @param ptsPerGrpReq Requested number of points in each annotation group.
#' @param extraFields Fields, in addition to the default fields, that should be uploaded to GEE.
#' @export
prepForGEE <- function(dat,datAnnoIdPF,geeShapefileP,ptsPerGrpReq=NULL,extraFields=NULL) {

  defaultFields <- c('anno_id','lon','lat','timestamp')
  uploadFields <- c(defaultFields,extraFields)

  #anno_id is a temporary, ephmeral id that is added to a dataset during the annotation process
  # this is is used to match records from the original file to annotated records, after annotated
  # data is returned from GEE.
  dat <- dat %>% dplyr::mutate(anno_id=dplyr::row_number())

  #save the original dataset, this will have the annotated data joined to it once annotation is complete
  dir.create(dirname(datAnnoIdPF),recursive=TRUE,showWarnings=FALSE) #create the temporary folder

  message(glue::glue('Saving dataset will anno_id added to {datAnnoIdPF}'))
  readr::write_csv(dat, datAnnoIdPF)

  #----
  #---- Add group number ----
  #----

  #so that annotation can be broken up into groups
  #TODO: make this zero based, easier for for() loop in ee?
  if(!is.null(ptsPerGrpReq)) {
    if(ptsPerGrpReq < nrow(dat)) {
      numGrps <- floor(nrow(dat)/ptsPerGrpReq)
      ptsPerGrp <- ceiling(nrow(dat)/numGrps)
      anno_grp <- rep(1:numGrps,each=ptsPerGrp)[1:nrow(dat)]

      dat$anno_grp <- anno_grp
      uploadFields <- c('anno_grp',uploadFields)
      message(glue::glue('Number of groups is {numGrps}'))
    } else {
      message(glue::glue('Number of points requested per group ({ptsPerGrpReq}) is more than the total number of points ({nrow(dat)}). Not assigning groups.'))
    }
  }

  #----
  #---- Prep the dataset for GEE ----#
  #----
  message('Creating GEE formatted shapefile...')

  #--- filter fields to just required fields, plus any extra fields specified in function call.
  dat <- dat %>% dplyr::select_(.dots=uploadFields)

  #convert datetimes to strings that are parseable by GEE.
  message('Converting timestamps, assuming they are GMT time zone.')
  dat$timestamp <- strftime(dat$timestamp, format="%Y-%m-%dT%H:%M:%SZ",tz='GMT') #make sure to specify GMT!!

  #----
  #---- Save as shapefile ----#
  #----

  message('Assuming points are geographic WGS84 coordinates.')
  trsp <- as.data.frame(dat)
  sp::coordinates(trsp) <- ~lon+lat
  sp::proj4string(trsp) <- sp::CRS('+proj=longlat +datum=WGS84')

  # note here that point_index is saved as a floating point instead of an integer
  #  this is because r doesn't seem to support large integers (such as long or int64)
  message(glue::glue('Writing shapefile to {geeShapefileP}'))
  dir.create(geeShapefileP,recursive=TRUE,showWarnings=FALSE)
  rgdal::writeOGR(obj=trsp, dsn=geeShapefileP, layer=basename(geeShapefileP), driver="ESRI Shapefile", overwrite_layer = TRUE)

  message(glue::glue('Success.'))
  return(TRUE)
}

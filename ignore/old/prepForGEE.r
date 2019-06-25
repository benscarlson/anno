

#' Preps dataset for annotation in GEE.
#' 1) Saves a copy of the data, but with anno_id added as a column.
#' 2) Saves a shapefile formatted for upload to GEE.
#'
#' @param datPF Path to dataset to annotate.
#' @param annoPF Path and Filename specifying where to save original dataset, with anno_id added.
#' @param shpDSN Path of output shapefile, prepped for GEE. Final folder will be the name of the shapefile.
#' @param ptsPerGrp Requested number of points in each annotation group.
#' @param extFields Fields, in addition to the default fields, that should be uploaded to GEE.
#' @export
prepForGEE <- function(datPF,annoPF=NULL,shpDSN=NULL,ptsPerGrp=getOption('anno.ptsPerGrp'),extFields=NULL) {

  if(file.exists(datPF)) {
    message(glue::glue('Loading {datPF}...'))
    dat <- readr::read_csv(datPF,col_type=readr::cols())
  } else {
    stop(glue::glue('Unable to find {datPF}. Exiting...'))
  }

  #datPF <- '/users/benc/myfile.csv'
  #datPF <- 'myfile.csv'

  if(is.null(annoPF)) { #build path and filename based on datPF
    annoFN <- sub('\\.csv$','', basename(datPF), ignore.case=TRUE)
    annoFN <- paste0(annoFN,getOption('anno.annoSuffix'),'.csv')
    annoPF <- file.path(dirname(datPF),annoFN)
  }

  if(is.null(shpDSN)) { #use name of datPF for shape dsn
    shpDSN <- sub('\\.csv$','', datPF, ignore.case=TRUE)
  }

  defaultFields <- c('anno_id','lon','lat','timestamp')
  uploadFields <- c(defaultFields,extFields)

  #anno_id is a temporary, ephmeral id that is added to a dataset during the annotation process
  # this is is used to match records from the original file to annotated records, after annotated
  # data is returned from GEE.
  dat <- dat %>% dplyr::mutate(anno_id=dplyr::row_number())

  #save the original dataset, with anno_id added to it. this will have the annotated data joined to it once annotation is complete
  dir.create(dirname(annoPF),recursive=TRUE,showWarnings=FALSE) #create the temporary folder
  message(glue::glue('Saving dataset with anno_id added to {annoPF}'))
  readr::write_csv(dat, annoPF)

  #----
  #---- Add group number ----
  #----

  #so that annotation can be broken up into groups
  #TODO: make this zero based, easier for for() loop in ee?
  #TODO: maybe always
  if(!is.null(ptsPerGrp)) {
    if(ptsPerGrp < nrow(dat)) {
      numGrps <- floor(nrow(dat)/ptsPerGrp)
      ptsPerGrp <- ceiling(nrow(dat)/numGrps)
      anno_grp <- rep(1:numGrps,each=ptsPerGrp)[1:nrow(dat)]

      dat$anno_grp <- anno_grp
      uploadFields <- c('anno_grp',uploadFields)
      message(glue::glue('Number of groups is {numGrps}'))
    } else {
      message(glue::glue('Number of points requested per group ({ptsPerGrp}) is more than the total number of points ({nrow(dat)}). Not assigning groups.'))
    }
  } else {
    message('ptsPerGrp is null, but should not be.')
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
  message(glue::glue('Writing shapefile to {shpDSN}'))
  dir.create(shpDSN,recursive=TRUE,showWarnings=FALSE)
  rgdal::writeOGR(obj=trsp, dsn=shpDSN, layer=basename(shpDSN), driver="ESRI Shapefile", overwrite_layer = TRUE)

  message(glue::glue('Success.'))
  return(TRUE)
}

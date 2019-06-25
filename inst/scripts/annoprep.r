#!/usr/bin/env Rscript

spsm <- suppressPackageStartupMessages

spsm(library(docopt))
spsm(library(glue))
spsm(library(tidyverse))

'Prep for GEE.

Usage:
annoprep.r <dat> [options]

Options:
-h --help     Show this screen.
-v --version     Show version.
--ptsPerGrp=<ptsPerGrp>
--extFields=<extFields>

' -> doc

#Note docopt initializes parameters that are not passed in to NULL
ag <- docopt(doc, version = '0.1\n')

if(FALSE) {
  ag <- list(dat='~/scratch/obs.csv', #copy anno/inst/testdata/obs.csv to scratch
             ptsPerGrp=10,
             extFields=NULL)
}

#These match what is set in zzz.r options. In the future, full from a yml file?
anno.ptsPerGrp <- 250000 #default annotation group size
anno.annoSuffix <- '_anno' #default suffix for annotated file
anno.geeSuffix <- '_foree' #default suffix for annotated file

if(is.null(ag$ptsPerGrp)) {
  ag$ptsPerGrp <- anno.ptsPerGrp
} else {
  ag$ptsPerGrp <- as.integer(ag$ptsPerGrp)
}

if(!is.null(ag$extFields)) {
  ag$extFields <- trimws(strsplit(ag$extFields,split=',')[[1]])
}

if(file.exists(ag$dat)) {
  message(glue::glue('Loading {ag$dat}...'))
  df <- read_csv(ag$dat,col_type=readr::cols())
} else {
  stop(glue('Unable to find {ag$dat}. Exiting...'))
}

fileBN <- sub('\\.csv$','', basename(ag$dat), ignore.case=TRUE)
#this file receives anno_id. Annotated data will be joined to it.
annoFN <- paste0(fileBN,anno.annoSuffix,'.csv')
annoPF <- file.path(dirname(ag$dat),annoFN)
#this file has minimal columns and is uploaded to gee
geeFN <- paste0(fileBN,anno.geeSuffix,'.csv')
geePF <- file.path(dirname(ag$dat),geeFN)

defaultFields <- c('anno_id','lon','lat','timestamp')
uploadFields <- c(defaultFields,ag$extFields)

#anno_id is a temporary, ephmeral id that is added to a dataset during the annotation process
# this is is used to match records from the original file to annotated records, after annotated
# data is returned from GEE.
message(glue::glue('Saving dataset with anno_id added to {annoPF}'))
df <- df %>% dplyr::mutate(anno_id=row_number()) %>%
  write_csv(annoPF)

#----
#---- Add group number ----
#----

#so that annotation can be broken up into groups
#TODO: make this zero based, easier for for() loop in ee?
if(!is.null(ag$ptsPerGrp)) {
  if(ag$ptsPerGrp < nrow(df)) {
    numGrps <- floor(nrow(df)/ag$ptsPerGrp)

    ptsPerGrpAct <- ceiling(nrow(df)/numGrps) #actual number of points per group
    anno_grp <- rep(1:numGrps,each=ptsPerGrpAct)[1:nrow(df)]

    df$anno_grp <- anno_grp
    uploadFields <- c('anno_grp',uploadFields)
    message(glue('Number of groups is {numGrps}'))
  } else {
    message(glue('Number of points requested per group ({ag$ptsPerGrp}) is more than the total number of points ({nrow(df)}). Not assigning groups.'))
  }
} else {
  stop('ptsPerGrp is null, but should not be.')
}

#----
#---- Prep the dataset for GEE ----#
#----

#TODO: save this in a *_anno folder?
message('Converting timestamps, assuming they are GMT time zone.')
message(glue('Writing dataset that will be uploaded to GEE to file {geePF}'))
df %>% dplyr::select_(.dots=uploadFields) %>% #filter fields to just required fields, plus any extra fields specified in function call.
  dplyr::mutate(timestamp=strftime(timestamp,format="%Y-%m-%dT%H:%M:%SZ",tz='GMT')) %>% #make sure to specify GMT!!
  readr::write_csv(geePF)

#TODO: make this function key off something besides datName
# Instead, locally use the name of the file, and then use geeName in gee and gcs?

# Join the annotated data back to the original data
#' @importFrom glue glue
#' @importFrom readr read_csv
#' @import dplyr
#' @import tidyr
#' @export
#'
joinOrigData <- function(datAnno,datName) {
  #---- common variable header ----#
  scratchP <- glue('tempfolder_{datName}') #path of temporary files used in annotation
  datCopyFN <- glue('{datName}_original.csv') #file name for copy of original file
  #---- ----#

  origPN <- file.path(scratchP,datCopyFN)

  if(file.exists(origPN)) {
    #get the original file, which has anno_id
    message("Joining to original file...")
    datOrig <- read_csv(origPN,col_types=cols())

    #join datAnno to the original datName
    dat <- datOrig %>%
      left_join(datAnno, by='anno_id') %>%
      select(-anno_id)
  } else {
    message("Not joining results to the originally uploaded file, because this file can't be found.")
    dat <- datAnno
  }
}

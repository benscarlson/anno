
#' High-level function that processes raw GEE results.
#' Converts to wide format (one variable per column).
#' Converts units if necessary.
#' Joins to an existing file (file must have anno_id).
#'
#' @param datAnnoPF \code{character} Path and filename of the file that the anno data should be joined to. Should have anno_id field.
#' @param outPF \code{character} Path and filename of output file. Will write over datAnnoPF if null
#' @param rawP \code{character} Path to raw GEE result files. If NULL, assumes ./raw
#' @export
#'
processGEEraw <- function(datAnnoPF,outPF=NULL,rawP=NULL) {
  #TODO: could update the function so that datAnnoPF is
  # Then, there is no joining to an existing dataset, just save it
  # In this case, if datAnnoPF is null, then outPF can't be null.

  if(is.null(rawP)) {
    rawP <- getOption('anno.rawP')
  }

  geeAnno <- annoRawToWide(rawP) %>%
    convertUnits()

  message("Joining annotated data...")

  #need to increase default number of guessed rows in cases where there are a lot of nulls
  datAnno <- readr::read_csv(datAnnoPF,col_type=readr::cols(),guess_max=nrow(geeAnno)/5)

  # join annotated variables to the original dataset (must have anno_id)
  datAnno <- datAnno %>%
    dplyr::left_join(geeAnno, by='anno_id')

  if(is.null(outPF)) {
    outPF <- datAnnoPF
  }

  message(glue::glue('Writing dataset...'))
  readr::write_csv(datAnno,outPF)

}

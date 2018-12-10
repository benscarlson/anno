
#' High-level function that processes raw GEE results.
#' Converts to wide format (one variable per column).
#' Converts units if necessary.
#' Optionally joins to an existing file (file must have anno_id).
#'
#' @param rawP Path to raw GEE result files
#' @param joinToPF Path and filename of the file that the anno data should be joined to. Should have anno_id field.
#' @export
#'
processGEEraw <- function(rawP,joinToDat=NULL) {

  datAnno <- annoRawToWide(rawP)
  datAnno <- convertUnits(datAnno)

  if(!is.null(joinToDat)) {
    #Join to specified dataset. Must have anno_id.
    message(glue::glue("Joining annotated data..."))

    #join annotated data to specified file (usually the original data)
    datAnno <- joinToDat %>%
      dplyr::left_join(datAnno, by='anno_id')
  } else {
    datAnno <- datAnno
  }

  message('Processing raw GEE data was successful.')
  return(datAnno)
}


#' Assumes tracksName has lon, lat, timestamp columns
#' Assumes that all timestamps are in GMT, lon/lat is WGS84
dfTracksToShape <- function(dat,dsn,layer) {


  if(is.null(dat)) {
    stop('Need to provide a data.frame.')
  }


}

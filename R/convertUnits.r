# The idea here is to somehow match specific variables by gee id to specific
# post-processing steps. So, as I build up more vars here, I should make this table larger.
# eventually could move to csv file.
envRef <- tibble::tribble(
  ~env_label,         ~env_id,
  'EVIMOD_16day_250m','MODIS/006/MOD13Q1',
  'EVIMYD_16day_250m','MODIS/006/MYD13Q1',
  'LSTMOD_8day_1km','MODIS/006/MOD11A2',
  'LSTMYD_8day_1km','MODIS/006/MYD11A2')

transMODIS_LST  <- function(raw) {
  c <- (raw*0.02)-273.15
  return(c)
}

transMODIS_EVI <- function(raw) {
  return(raw*0.0001)
}

# Converts low-level units. Remote sensing data are often stored in different units.
#
convertUnits <- function(datAnno) {

  envLabs <- names(dplyr::select(datAnno,-anno_id)) #get all the variable names

  message('Performing low-level unit conversion.')
  for(envLab in envLabs) {
    #get the envId associated with this envlab
    envId <- dplyr::filter(envRef,env_label==envLab)$env_id

    # TODO: even better, put name of function into the lookup table??
    #   This method is not very expandable!
    if(length(envId)>0) {
      if(envId %in% c('MODIS/006/MOD13Q1','MODIS/006/MYD13Q1')) { #MODIS EVI variables
        # convert MODIS EVI units to range 0-1
        message(envId)
        datAnno <- datAnno %>%
          dplyr::mutate(!!envLab := transMODIS_EVI(!!as.name(envLab)))
      } else if(envId  %in% c('MODIS/006/MOD11A2','MODIS/006/MYD11A2')) { #MODIS LST variables
        # convert MODIS LST units to degrees C
        message(envId)
        datAnno <- datAnno %>%
          dplyr::mutate(!!envLab := transMODIS_LST(!!as.name(envLab)))
      }
    }
  }

  message('Processing raw GEE data was successful.')
  return(datAnno)

}

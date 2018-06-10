# processes raw GEE output and joins back to original dataset
# returns a list that contains the dataset and a vector of environmental variable labels

procGEEoutput <- function(datName) {
  if(FALSE) {datName<-'test_beu'}

  select <- dplyr::select

  scratchP <- file.path(.annoP,glue('anno_{datName}')) #path of temporary files used in annotation

  datAnno <- annoRawToWide(datName)
  envLabs <- names(select(datAnno,-anno_id))

  datCopyFN <- glue('{datName}_original.csv') #copy of original file

  datOrig <- read_csv(file.path(scratchP,datCopyFN))

  #join datAnno to the original datName
  datJoin <- datOrig %>%
    left_join(datAnno, by='anno_id') %>%
    dplyr::select(-anno_id)

  return(list(dat=datJoin,envLabs=envLabs))
}

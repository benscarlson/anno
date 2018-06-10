
function(datAnno, dataset) {
  datOrig <- read_csv(sprintf('scratch/%s/%s_original.csv', dataset, dataset))
  
  #join datAnno to the original data set using index
  datOrigAnno <- datAnno %>%
    left_join(
      datAnno %>% dplyr::select(index,one_of(envs)), by='index')
}

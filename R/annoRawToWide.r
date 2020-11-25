#' Combines GEE formatted CSV file output and translates into wide format
#'
#' @param rawP Path to raw GEE result files
#' @importFrom magrittr %>%
#' @export
annoRawToWide <- function(rawP) {

  #if splitting up annotation of an single variable (i.e. EVI) into multiple runs/files, can still
  #just run this code, because all files are just stacked on top of each other.

  message(glue::glue('Reading files from {rawP}'))
  rawFiles <- list.files(rawP,full.names=TRUE)
  message('Found the following raw files...')
  print(rawFiles)

  colTypes = readr::cols(`system:index`=readr::col_skip(),
                  anno_id=readr::col_double(),
                  env_val=readr::col_double(),
                  .geo=readr::col_skip())

  message('Combining files...')
  annoRawList <- lapply(rawFiles,function(fileName) {
    dat0 <- readr::read_csv(fileName, col_types=colTypes)
    if(!('env_val' %in% colnames(dat0))) {
      message(sprintf('Env values missing for %s, not including in results',unique(dat0$env_label)))
      dat0 <- NULL
    }

    #return with columns sorted alphabetically.
    return(dat0)
  })

  annoRaw <- dplyr::bind_rows(annoRawList) %>% dplyr::filter(env_label != 'fake row')
  #annoRaw <- annoRaw %>% rename(row_index=point_index) #do this for now! (should be anno_id anyway)

  envs <- unique(annoRaw$env_label)
  #print(paste(envs,collapse=','))
  message('Checking if there are duplicate values for a point & layer. This happens when time periods overlap, usually in the new year.')

  dups <- annoRaw %>%
    dplyr::group_by(anno_id,env_label) %>%
    dplyr::summarize(num=dplyr::n()) %>%
    dplyr::filter(num > 1) %>%
    nrow()

  if(dups==0) {
    message('No duplicates')
    annoMean <- annoRaw %>% dplyr::select(-env_id,-image_id)
  } else {
    message(glue::glue('{dups} duplicates found, taking mean'))
    annoMean <- annoRaw %>%
      dplyr::group_by(anno_id,env_label) %>%
      dplyr::summarize(env_val=mean(env_val,na.rm=TRUE)) %>%
      dplyr::ungroup()
  }

  # long to wide format
  annoWide <- annoMean %>%
    tidyr::spread(env_label,env_val) %>%
    dplyr::select(anno_id,dplyr::one_of(envs))

  return(annoWide)
}



library(dplyr)
library(readr)

.resultsP <- '/Users/benc/projects/whitestork/results/stpp_models/beuster_sum13'

#---- load data ----#
ents <- read_csv(file.path(.resultsP,'entities.csv'),col_types=cols())
dat0 <- read_csv(file.path(.resultsP,'data/obsbg.csv'),col_types=cols()) %>%
  left_join(select(ents,individual_id,short_name),by='individual_id')

test_data <- dat0 %>% slice(1:60)

devtools::use_data(test_data)

obs <- read_csv('inst/testdata/obs_anno.csv')
obs %>% select(anno_id,lon,lat,timestamp,short_name) %>%
  mutate(timestamp=strftime(timestamp, format="%Y-%m-%dT%H:%M:%SZ",tz='GMT')) %>%
  write_csv('inst/testdata/obs_anno_foree.csv')

#somehow this folder & file should be ignored when building source

library(dplyr)
load(file='/Users/benc/projects/anno/data/test_data.rda')

write_csv(test_data,'/Users/benc/projects/anno/inst/testdata/obs.csv')

obsanno <- test_data %>% mutate(anno_id=dplyr::row_number())

write_csv(obsanno,'/Users/benc/projects/anno/inst/testdata/obs_anno.csv')

rawP <- '/Users/benc/projects/whitestork/results/stpp_models/loburg_sum14_new/data/raw'
testdatP <- '/Users/benc/projects/anno/inst/testdata/'

dist2urban <- read_csv(file.path(rawP,'loburg_sum14_new_dist2urban_1_ee_export.csv')) %>%
  filter(anno_id <= 60)

evi <- read_csv(file.path(rawP,'loburg_sum14_new_EVIMOD_16day_250m_1_ee_export.csv')) %>%
  filter(anno_id <= 60)

write_csv(dist2urban,file.path(testdatP,'raw/test_dist2urban_1_ee_export.csv'))
write_csv(evi,file.path(testdatP,'raw/test_EVIMOD_16day_250m_1_ee_export.csv'))

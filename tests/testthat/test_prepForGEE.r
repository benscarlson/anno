context('prepForGEE')

#TODO: need to use relative paths and temporary directories
load(file='/Users/benc/projects/anno/data/test_data.rda')

test_that('can prep gee', {
  expect_true(prepForGEE(dat=test_data,
    datAnnoIdPF='/Users/benc/scratch/anno/test_data_anno.csv',
    geeShapefileP='/Users/benc/scratch/anno/test_data_anno'))
})

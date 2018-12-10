context('processGeeRaw')

test_that('can run', {
  joinToDat <- readr::read_csv('~/scratch/anno/test_data_anno.csv',col_types=readr::cols())

  datAnno <- processGEEraw(
    rawP='~/scratch/anno/test_data_anno_raw',
    joinToDat=joinToDat)

  expect_equal(
    class(data.frame(datAnno)),
    'data.frame')
})

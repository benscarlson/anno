context('convertUnits')

test_that('can run', {
  datAnno <- annoRawToWide(rawP='~/scratch/anno/test_data_anno_raw')

  datConv <- convertUnits(datAnno)

  expect_equal(
    class(data.frame(datConv)),
    'data.frame')
})

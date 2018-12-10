context('annoRawToWide')

test_that('can run', {
  expect_equal(
    class(data.frame(annoRawToWide(rawP='~/scratch/anno/test_data_anno_raw'))),
    'data.frame')
})

context('processGeeRaw')

testdatP <- system.file("testdata",package="anno")

test_that('test add two variables', {

  tempP <- tempdir()
  tempPF <- tempfile(tmpdir=tempP,fileext='.csv')

  processGEEraw(
    datAnnoPF=file.path(testdatP,'obs_anno.csv'),
    outPF=tempPF,
    rawP=file.path(testdatP,'raw')) #note raw folder containts two annotated variables

  datAnnoPre <- read_csv(file.path(testdatP,'obs_anno.csv'),col_types=cols())
  datAnnoPost <- read_csv(tempPF,col_types=cols())

  #should have appended two variables
  expect_equal(ncol(datAnnoPost)-ncol(datAnnoPre),2)

  #number of rows should be equal
  expect_equal(nrow(datAnnoPost),nrow(datAnnoPre))
})

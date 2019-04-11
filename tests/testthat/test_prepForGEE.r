context('prepForGEE')

#TODO: move this to inst/testdata?
load(file='/Users/benc/projects/anno/data/test_data.rda')

test_that('use full path', {
  tempP <- tempdir()
  csvPF <- tempfile(tmpdir=tempP,fileext='.csv')

  write_csv(test_data,csvPF)

  expect_true(prepForGEE(dat=csvPF))

})

test_that('use dat file name and cwd', {
  tempP <- tempdir()
  csvPF <- tempfile(tmpdir=tempP,fileext='.csv')

  write_csv(test_data,csvPF)

  wd <- getwd()

  setwd(tempP) #simulate annotating a file in the cwd

  expect_true(prepForGEE(dat=basename(csvPF)))

  setwd(wd)

})

test_that('set anno and shape file names', {
  tempP <- tempdir()
  csvPF <- tempfile(tmpdir=tempP,fileext='.csv')

  write_csv(test_data,csvPF)

  expect_true(prepForGEE(dat=csvPF,
   annoPF=file.path(tempP,'test_data_anno.csv'),
   shpDSN=file.path(tempP,'test_data_anno'))) #/Users/benc/scratch/anno/
})

test_that('use default ptsPerGrp', {

  tempP <- tempdir()
  csvPF <- tempfile(tmpdir=tempP,fileext='.csv')

  write_csv(test_data,csvPF)

  opt <- getOption("anno.ptsPerGrp")
  options(anno.ptsPerGrp=10) #set group size lower so that test will work

  expect_true(prepForGEE(dat=csvPF,
    shpDSN=file.path(tempP,'test_ppg_default')))

  options(anno.ptsPerGrp=opt)

  #since num rows (60) > requested group size (10), anno_grp field will be added.
  expect_true('anno_grp' %in%
    names(readOGR(dsn=file.path(tempP,'test_ppg_default'), layer="test_ppg_default")))

})

test_that('supply ptsPerGrp', {

  tempP <- tempdir()
  csvPF <- tempfile(tmpdir=tempP,fileext='.csv')

  write_csv(test_data,csvPF)

  expect_true(prepForGEE(dat=csvPF,
    shpDSN=file.path(tempP,'test_ppg_supply'),
    ptsPerGrp=10))

  #since num rows (60) > requested group size (10), anno_grp field will be added.
  expect_true('anno_grp' %in%
                names(readOGR(dsn=file.path(tempP,'test_ppg_supply'), layer="test_ppg_supply")))

})


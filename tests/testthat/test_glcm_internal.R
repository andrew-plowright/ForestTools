context("Tests for internal GLCM functions")

# Load test data
load('test_data/glcm-hallbey.rda')
load('test_data/glcm-tumor.rda')
load('test_data/glcm-noise.rda')
load('test_data/glcm-bars.rda')

test_that("0 degree GLCM properly calculates", {
  expect_equal(.glcm_calc(hallbey, angle=0, n_grey = 32), as.matrix(read.table("validation_data/glcm/hallbey0.csv",   header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.glcm_calc(tumor,   angle=0, n_grey = 32), as.matrix(read.table("validation_data/glcm/tumor0.csv",     header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.glcm_calc(noise,   angle=0, n_grey = 32), as.matrix(read.table("validation_data/glcm/noise0.csv",     header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.glcm_calc(bars,    angle=0, n_grey = 32), as.matrix(read.table("validation_data/glcm/bars0.csv",      header=TRUE, sep=",", check.names=FALSE)))

})

test_that("45 degree GLCM properly calculates", {
  expect_equal(.glcm_calc(hallbey, angle=45, n_grey = 32), as.matrix(read.table("validation_data/glcm/hallbey45.csv", header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.glcm_calc(tumor,   angle=45, n_grey = 32), as.matrix(read.table("validation_data/glcm/tumor45.csv",   header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.glcm_calc(noise,   angle=45, n_grey = 32), as.matrix(read.table("validation_data/glcm/noise45.csv",   header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.glcm_calc(bars,    angle=45, n_grey = 32), as.matrix(read.table("validation_data/glcm/bars45.csv",    header=TRUE, sep=",", check.names=FALSE)))

})

test_that("90 degree GLCM properly calculates", {
  expect_equal(.glcm_calc(hallbey, angle=90, n_grey = 32), as.matrix(read.table("validation_data/glcm/hallbey90.csv", header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.glcm_calc(tumor,   angle=90, n_grey = 32), as.matrix(read.table("validation_data/glcm/tumor90.csv",   header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.glcm_calc(noise,   angle=90, n_grey = 32), as.matrix(read.table("validation_data/glcm/noise90.csv",   header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.glcm_calc(bars,    angle=90, n_grey = 32), as.matrix(read.table("validation_data/glcm/bars90.csv",    header=TRUE, sep=",", check.names=FALSE)))

})

test_that("135 degree GLCM properly calculates", {
  expect_equal(.glcm_calc(hallbey, angle=135, n_grey = 32), as.matrix(read.table("validation_data/glcm/hallbey135.csv", header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.glcm_calc(tumor,   angle=135, n_grey = 32), as.matrix(read.table("validation_data/glcm/tumor135.csv",   header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.glcm_calc(noise,   angle=135, n_grey = 32), as.matrix(read.table("validation_data/glcm/noise135.csv",   header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.glcm_calc(bars,    angle=135, n_grey = 32), as.matrix(read.table("validation_data/glcm/bars135.csv",    header=TRUE, sep=",", check.names=FALSE)))

})


test_that("0 degree GLCM features are properly calculated", {
  expect_equal(.glcm_stats(.glcm_calc(hallbey, angle=0, n_grey = 32)), read.csv("validation_data/glcm_features/hallbey0.csv",   stringsAsFactors=FALSE))
  expect_equal(.glcm_stats(.glcm_calc(tumor,   angle=0, n_grey = 32)), read.csv("validation_data/glcm_features/tumor0.csv",     stringsAsFactors=FALSE))
  expect_equal(.glcm_stats(.glcm_calc(noise,   angle=0, n_grey = 32)), read.csv("validation_data/glcm_features/noise0.csv",     stringsAsFactors=FALSE))
  expect_equal(.glcm_stats(.glcm_calc(bars,    angle=0, n_grey = 32)), read.csv("validation_data/glcm_features/bars0.csv",      stringsAsFactors=FALSE))

})

test_that("45 degree GLCM features are properly calculated", {
  expect_equal(.glcm_stats(.glcm_calc(hallbey, angle=45, n_grey = 32)), read.csv("validation_data/glcm_features/hallbey45.csv", stringsAsFactors=FALSE))
  expect_equal(.glcm_stats(.glcm_calc(tumor,   angle=45, n_grey = 32)), read.csv("validation_data/glcm_features/tumor45.csv",   stringsAsFactors=FALSE))
  expect_equal(.glcm_stats(.glcm_calc(noise,   angle=45, n_grey = 32)), read.csv("validation_data/glcm_features/noise45.csv",   stringsAsFactors=FALSE))
  expect_equal(.glcm_stats(.glcm_calc(bars,    angle=45, n_grey = 32)), read.csv("validation_data/glcm_features/bars45.csv",    stringsAsFactors=FALSE))

})

test_that("90 degree GLCM features are properly calculated", {
  expect_equal(.glcm_stats(.glcm_calc(hallbey, angle=90, n_grey = 32)), read.csv("validation_data/glcm_features/hallbey90.csv", stringsAsFactors=FALSE))
  expect_equal(.glcm_stats(.glcm_calc(tumor,   angle=90, n_grey = 32)), read.csv("validation_data/glcm_features/tumor90.csv",   stringsAsFactors=FALSE))
  expect_equal(.glcm_stats(.glcm_calc(noise,   angle=90, n_grey = 32)), read.csv("validation_data/glcm_features/noise90.csv",   stringsAsFactors=FALSE))
  expect_equal(.glcm_stats(.glcm_calc(bars,    angle=90, n_grey = 32)), read.csv("validation_data/glcm_features/bars90.csv",    stringsAsFactors=FALSE))

})

test_that("135 degree GLCM features are properly calculated", {
  expect_equal(.glcm_stats(.glcm_calc(hallbey, angle=135, n_grey = 32)), read.csv("validation_data/glcm_features/hallbey135.csv", stringsAsFactors=FALSE))
  expect_equal(.glcm_stats(.glcm_calc(tumor,   angle=135, n_grey = 32)), read.csv("validation_data/glcm_features/tumor135.csv",   stringsAsFactors=FALSE))
  expect_equal(.glcm_stats(.glcm_calc(noise,   angle=135, n_grey = 32)), read.csv("validation_data/glcm_features/noise135.csv",   stringsAsFactors=FALSE))
  expect_equal(.glcm_stats(.glcm_calc(bars,    angle=135, n_grey = 32)), read.csv("validation_data/glcm_features/bars135.csv",    stringsAsFactors=FALSE))

})

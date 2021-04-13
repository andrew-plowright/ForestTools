context("Tests for internal GLCM functions")

# Load test data
load('testData/glcm-hallbey.rda')
load('testData/glcm-tumor.rda')
load('testData/glcm-noise.rda')
load('testData/glcm-bars.rda')

test_that("0 degree GLCM properly calculates", {
  expect_equal(.calcGLCM(hallbey, angle=0, n_grey = 32), as.matrix(read.table("validationData/glcm/hallbey0.csv",        header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.calcGLCM(tumor,   angle=0, n_grey = 32), as.matrix(read.table("validationData/glcm/tumor0.csv",     header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.calcGLCM(noise,   angle=0, n_grey = 32), as.matrix(read.table("validationData/glcm/noise0.csv",     header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.calcGLCM(bars,    angle=0, n_grey = 32), as.matrix(read.table("validationData/glcm/bars0.csv",      header=TRUE, sep=",", check.names=FALSE)))

})

test_that("45 degree GLCM properly calculates", {
  expect_equal(.calcGLCM(hallbey, angle=45, n_grey = 32), as.matrix(read.table("validationData/glcm/hallbey45.csv",      header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.calcGLCM(tumor,   angle=45, n_grey = 32), as.matrix(read.table("validationData/glcm/tumor45.csv",   header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.calcGLCM(noise,   angle=45, n_grey = 32), as.matrix(read.table("validationData/glcm/noise45.csv",   header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.calcGLCM(bars,    angle=45, n_grey = 32), as.matrix(read.table("validationData/glcm/bars45.csv",    header=TRUE, sep=",", check.names=FALSE)))

})

test_that("90 degree GLCM properly calculates", {
  expect_equal(.calcGLCM(hallbey, angle=90, n_grey = 32), as.matrix(read.table("validationData/glcm/hallbey90.csv",      header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.calcGLCM(tumor,   angle=90, n_grey = 32), as.matrix(read.table("validationData/glcm/tumor90.csv",   header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.calcGLCM(noise,   angle=90, n_grey = 32), as.matrix(read.table("validationData/glcm/noise90.csv",   header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.calcGLCM(bars,    angle=90, n_grey = 32), as.matrix(read.table("validationData/glcm/bars90.csv",    header=TRUE, sep=",", check.names=FALSE)))

})

test_that("135 degree GLCM properly calculates", {
  expect_equal(.calcGLCM(hallbey, angle=135, n_grey = 32), as.matrix(read.table("validationData/glcm/hallbey135.csv",    header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.calcGLCM(tumor,   angle=135, n_grey = 32), as.matrix(read.table("validationData/glcm/tumor135.csv", header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.calcGLCM(noise,   angle=135, n_grey = 32), as.matrix(read.table("validationData/glcm/noise135.csv", header=TRUE, sep=",", check.names=FALSE)))
  expect_equal(.calcGLCM(bars,    angle=135, n_grey = 32), as.matrix(read.table("validationData/glcm/bars135.csv",  header=TRUE, sep=",", check.names=FALSE)))

})


test_that("0 degree GLCM features are properly calculated", {
  expect_equal(.GLCMstats(.calcGLCM(hallbey, angle=0, n_grey = 32)), read.csv("validationData/glcm_features/hallbey0.csv",        stringsAsFactors=FALSE))
  expect_equal(.GLCMstats(.calcGLCM(tumor,   angle=0, n_grey = 32)), read.csv("validationData/glcm_features/tumor0.csv",     stringsAsFactors=FALSE))
  expect_equal(.GLCMstats(.calcGLCM(noise,   angle=0, n_grey = 32)), read.csv("validationData/glcm_features/noise0.csv",     stringsAsFactors=FALSE))
  expect_equal(.GLCMstats(.calcGLCM(bars,    angle=0, n_grey = 32)), read.csv("validationData/glcm_features/bars0.csv",      stringsAsFactors=FALSE))

})

test_that("45 degree GLCM features are properly calculated", {
  expect_equal(.GLCMstats(.calcGLCM(hallbey, angle=45, n_grey = 32)), read.csv("validationData/glcm_features/hallbey45.csv",      stringsAsFactors=FALSE))
  expect_equal(.GLCMstats(.calcGLCM(tumor,   angle=45, n_grey = 32)), read.csv("validationData/glcm_features/tumor45.csv",   stringsAsFactors=FALSE))
  expect_equal(.GLCMstats(.calcGLCM(noise,   angle=45, n_grey = 32)), read.csv("validationData/glcm_features/noise45.csv",   stringsAsFactors=FALSE))
  expect_equal(.GLCMstats(.calcGLCM(bars,    angle=45, n_grey = 32)), read.csv("validationData/glcm_features/bars45.csv",    stringsAsFactors=FALSE))

})

test_that("90 degree GLCM features are properly calculated", {
  expect_equal(.GLCMstats(.calcGLCM(hallbey, angle=90, n_grey = 32)), read.csv("validationData/glcm_features/hallbey90.csv",      stringsAsFactors=FALSE))
  expect_equal(.GLCMstats(.calcGLCM(tumor,   angle=90, n_grey = 32)), read.csv("validationData/glcm_features/tumor90.csv",   stringsAsFactors=FALSE))
  expect_equal(.GLCMstats(.calcGLCM(noise,   angle=90, n_grey = 32)), read.csv("validationData/glcm_features/noise90.csv",   stringsAsFactors=FALSE))
  expect_equal(.GLCMstats(.calcGLCM(bars,    angle=90, n_grey = 32)), read.csv("validationData/glcm_features/bars90.csv",    stringsAsFactors=FALSE))

})

test_that("135 degree GLCM features are properly calculated", {
  expect_equal(.GLCMstats(.calcGLCM(hallbey, angle=135, n_grey = 32)), read.csv("validationData/glcm_features/hallbey135.csv",    stringsAsFactors=FALSE))
  expect_equal(.GLCMstats(.calcGLCM(tumor,   angle=135, n_grey = 32)), read.csv("validationData/glcm_features/tumor135.csv", stringsAsFactors=FALSE))
  expect_equal(.GLCMstats(.calcGLCM(noise,   angle=135, n_grey = 32)), read.csv("validationData/glcm_features/noise135.csv", stringsAsFactors=FALSE))
  expect_equal(.GLCMstats(.calcGLCM(bars,    angle=135, n_grey = 32)), read.csv("validationData/glcm_features/bars135.csv",  stringsAsFactors=FALSE))

})

context("Tests for internal GLCM functions")

# Load test data
load('test_data/glcm-hallbey.rda')
load('test_data/glcm-tumor.rda')
load('test_data/glcm-noise.rda')
load('test_data/glcm-bars.rda')

# Discretize images
hallbey_disc <- terra::as.matrix(.discretize_rast(terra::rast(hallbey), n_grey = 4),  wide = TRUE)
tumor_disc   <- terra::as.matrix(.discretize_rast(terra::rast(tumor),   n_grey = 32), wide = TRUE)
noise_disc   <- terra::as.matrix(.discretize_rast(terra::rast(noise),   n_grey = 32), wide = TRUE)
bars_disc    <- terra::as.matrix(.discretize_rast(terra::rast(bars),    n_grey = 20), wide = TRUE)



# Read function
read_validation_matrix <- function(name){
  as.matrix(read.table(file.path("validation_data/glcm", paste0(name, ".csv")),  header=TRUE, sep=",", check.names=FALSE, row.names = 1) )
}
read_validation_features <- function(name){
  read.csv(file.path("validation_data/glcm_features", paste0(name, ".csv")), stringsAsFactors = FALSE)
}

# Tests
test_that("0 degree GLCM properly calculates", {
  expect_equal(.glcm_calc(hallbey_disc, angle=0, n_grey = 4),  read_validation_matrix("hallbey0"))
  expect_equal(.glcm_calc(tumor_disc,   angle=0, n_grey = 32), read_validation_matrix("tumor0"))
  expect_equal(.glcm_calc(noise_disc,   angle=0, n_grey = 32), read_validation_matrix("noise0"))
  expect_equal(.glcm_calc(bars_disc,    angle=0, n_grey = 20), read_validation_matrix("bars0"))

})

test_that("45 degree GLCM properly calculates", {
  expect_equal(.glcm_calc(hallbey_disc, angle=45, n_grey = 32), read_validation_matrix("hallbey45"))
  expect_equal(.glcm_calc(tumor_disc,   angle=45, n_grey = 32), read_validation_matrix("tumor45"))
  expect_equal(.glcm_calc(noise_disc,   angle=45, n_grey = 32), read_validation_matrix("noise45"))
  expect_equal(.glcm_calc(bars_disc,    angle=45, n_grey = 20), read_validation_matrix("bars45"))

})

test_that("90 degree GLCM properly calculates", {
  expect_equal(.glcm_calc(hallbey_disc, angle=90, n_grey = 32), read_validation_matrix("hallbey90"))
  expect_equal(.glcm_calc(tumor_disc,   angle=90, n_grey = 32), read_validation_matrix("tumor90"))
  expect_equal(.glcm_calc(noise_disc,   angle=90, n_grey = 32), read_validation_matrix("noise90"))
  expect_equal(.glcm_calc(bars_disc,    angle=90, n_grey = 20), read_validation_matrix("bars90"))

})

test_that("135 degree GLCM properly calculates", {
  expect_equal(.glcm_calc(hallbey_disc, angle=135, n_grey = 32), read_validation_matrix("hallbey135"))
  expect_equal(.glcm_calc(tumor_disc,   angle=135, n_grey = 32), read_validation_matrix("tumor135"))
  expect_equal(.glcm_calc(noise_disc,   angle=135, n_grey = 32), read_validation_matrix("noise135"))
  expect_equal(.glcm_calc(bars_disc,    angle=135, n_grey = 20), read_validation_matrix("bars135" ))

})


test_that("0 degree GLCM features are properly calculated", {
  expect_equal(.glcm_stats(.glcm_calc(hallbey_disc, angle=0, n_grey = 4)), read_validation_features("hallbey0"))
  expect_equal(.glcm_stats(.glcm_calc(tumor_disc,   angle=0, n_grey = 32)), read_validation_features("tumor0"))
  expect_equal(.glcm_stats(.glcm_calc(noise_disc,   angle=0, n_grey = 32)), read_validation_features("noise0"))
  expect_equal(.glcm_stats(.glcm_calc(bars_disc,    angle=0, n_grey = 20)), read_validation_features("bars0"))

})

test_that("45 degree GLCM features are properly calculated", {
  expect_equal(.glcm_stats(.glcm_calc(hallbey_disc, angle=45, n_grey = 4)), read_validation_features("hallbey45"))
  expect_equal(.glcm_stats(.glcm_calc(tumor_disc,   angle=45, n_grey = 32)), read_validation_features("tumor45"))
  expect_equal(.glcm_stats(.glcm_calc(noise_disc,   angle=45, n_grey = 32)), read_validation_features("noise45"))
  expect_equal(.glcm_stats(.glcm_calc(bars_disc,    angle=45, n_grey = 20)), read_validation_features("bars45"))

})

test_that("90 degree GLCM features are properly calculated", {
  expect_equal(.glcm_stats(.glcm_calc(hallbey_disc, angle=90, n_grey = 4)), read_validation_features("hallbey90"))
  expect_equal(.glcm_stats(.glcm_calc(tumor_disc,   angle=90, n_grey = 32)), read_validation_features("tumor90"))
  expect_equal(.glcm_stats(.glcm_calc(noise_disc,   angle=90, n_grey = 32)), read_validation_features("noise90"))
  expect_equal(.glcm_stats(.glcm_calc(bars_disc,    angle=90, n_grey = 20)), read_validation_features("bars90"))

})

test_that("135 degree GLCM features are properly calculated", {
  expect_equal(.glcm_stats(.glcm_calc(hallbey_disc, angle=135, n_grey = 4)), read_validation_features("hallbey135"))
  expect_equal(.glcm_stats(.glcm_calc(tumor_disc,   angle=135, n_grey = 32)), read_validation_features("tumor135"))
  expect_equal(.glcm_stats(.glcm_calc(noise_disc,   angle=135, n_grey = 32)), read_validation_features("noise135"))
  expect_equal(.glcm_stats(.glcm_calc(bars_disc,    angle=135, n_grey = 20)), read_validation_features("bars135"))

})


test_that("Edge cases: all zeroes", {

  zero <- matrix(0, nrow=3, ncol=3)

  zero_glcm <- .glcm_calc(zero, angle=0, n_grey = 12)

  expect_equal(ncol(zero_glcm), 0)
  expect_equal(nrow(zero_glcm), 0)

  expect_true(all(.glcm_stats(zero_glcm) %in% list(NA, 0)))

})

test_that("Edge cases: 1x1", {

  one <- matrix(1, nrow=1, ncol=1)

  one_glcm <- .glcm_calc(one, angle=0, n_grey = 12)

  expect_equal(ncol(one_glcm), 1)
  expect_equal(nrow(one_glcm), 1)

  expect_true(all(.glcm_stats(one_glcm) %in% list(NaN, NA, 0)))

})

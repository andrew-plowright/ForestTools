# NOTE
# These tests are a holdover from when this package had its own function for making GLCMs
# Since 2024-04-27, ForestTools now delegates this to the external GLCMTextures library, which is tested here.
# It's debatable whether or not testing GLCMTextures is appropriate within the ForestTools package, but
# I've included these anyways just to ensure consistency of results

# Load test data
load('test_data/glcm-hallbey.rda')
load('test_data/glcm-tumor.rda')
load('test_data/glcm-noise.rda')
load('test_data/glcm-bars.rda')

metrics<- c("glcm_contrast", "glcm_dissimilarity", "glcm_homogeneity", "glcm_ASM", "glcm_entropy", "glcm_mean", "glcm_variance", "glcm_correlation")

# Discretize images
hallbey_disc <- terra::as.matrix(.discretize_rast(terra::rast(hallbey), n_grey = 4),  wide = TRUE)
tumor_disc   <- terra::as.matrix(.discretize_rast(terra::rast(tumor),   n_grey = 32), wide = TRUE)
noise_disc   <- terra::as.matrix(.discretize_rast(terra::rast(noise),   n_grey = 32), wide = TRUE)
bars_disc    <- terra::as.matrix(.discretize_rast(terra::rast(bars),    n_grey = 20), wide = TRUE)

# Read function
read_validation_matrix <- function(name){
  unname(as.matrix(read.table(file.path("validation_data/glcm", paste0(name, ".csv")), header=TRUE, sep=",", check.names=FALSE, row.names = 1) ) )
}
read_validation_metrics <- function(name){
  unlist(read.csv(file.path("validation_data/glcm_metrics", paste0(name, ".csv")), stringsAsFactors = FALSE))
}


# Tests
test_that("0 degree GLCM", {

  expect_equal(GLCMTextures::make_glcm(hallbey_disc - 1, shift=c(1,0), n_levels= 4), read_validation_matrix("hallbey0"), tolerance = 0.001)
  expect_equal(GLCMTextures::make_glcm(tumor_disc   - 1, shift=c(1,0), n_levels=32), read_validation_matrix("tumor0"),   tolerance = 0.001)
  expect_equal(GLCMTextures::make_glcm(noise_disc   - 1, shift=c(1,0), n_levels=32), read_validation_matrix("noise0"),   tolerance = 0.001)
  expect_equal(GLCMTextures::make_glcm(bars_disc    - 1, shift=c(1,0), n_levels=20), read_validation_matrix("bars0"),    tolerance = 0.001)

})

test_that("45 degree GLCM", {

  expect_equal(GLCMTextures::make_glcm(hallbey_disc - 1, shift=c(1,1), n_levels= 4), read_validation_matrix("hallbey45"), tolerance = 0.001)
  expect_equal(GLCMTextures::make_glcm(tumor_disc   - 1, shift=c(1,1), n_levels=32), read_validation_matrix("tumor45"),   tolerance = 0.001)
  expect_equal(GLCMTextures::make_glcm(noise_disc   - 1, shift=c(1,1), n_levels=32), read_validation_matrix("noise45"),   tolerance = 0.001)
  expect_equal(GLCMTextures::make_glcm(bars_disc    - 1, shift=c(1,1), n_levels=20), read_validation_matrix("bars45"),    tolerance = 0.001)

})

test_that("90 degree GLCM", {

  expect_equal(GLCMTextures::make_glcm(hallbey_disc - 1, shift=c(0,1), n_levels= 4), read_validation_matrix("hallbey90"), tolerance = 0.001)
  expect_equal(GLCMTextures::make_glcm(tumor_disc   - 1, shift=c(0,1), n_levels=32), read_validation_matrix("tumor90"),   tolerance = 0.001)
  expect_equal(GLCMTextures::make_glcm(noise_disc   - 1, shift=c(0,1), n_levels=32), read_validation_matrix("noise90"),   tolerance = 0.001)
  expect_equal(GLCMTextures::make_glcm(bars_disc    - 1, shift=c(0,1), n_levels=20), read_validation_matrix("bars90"),    tolerance = 0.001)

})

test_that("135 degree GLCM", {

  expect_equal(GLCMTextures::make_glcm(hallbey_disc - 1, shift=c(-1,1), n_levels= 4), read_validation_matrix("hallbey135"), tolerance = 0.001)
  expect_equal(GLCMTextures::make_glcm(tumor_disc   - 1, shift=c(-1,1), n_levels=32), read_validation_matrix("tumor135"),   tolerance = 0.001)
  expect_equal(GLCMTextures::make_glcm(noise_disc   - 1, shift=c(-1,1), n_levels=32), read_validation_matrix("noise135"),   tolerance = 0.001)
  expect_equal(GLCMTextures::make_glcm(bars_disc    - 1, shift=c(-1,1), n_levels=20), read_validation_matrix("bars135"),    tolerance = 0.001)

})

test_that("0 degree GLCM metrics", {

  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(hallbey_disc - 1, shift=c(1,0), n_levels= 4), metrics=metrics), read_validation_metrics("hallbey0")[metrics], tolerance = 0.001)
  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(tumor_disc   - 1, shift=c(1,0), n_levels=32), metrics=metrics), read_validation_metrics("tumor0")[metrics],   tolerance = 0.001)
  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(noise_disc   - 1, shift=c(1,0), n_levels=32), metrics=metrics), read_validation_metrics("noise0")[metrics],   tolerance = 0.001)
  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(bars_disc    - 1, shift=c(1,0), n_levels=20), metrics=metrics), read_validation_metrics("bars0")[metrics],    tolerance = 0.001)

})

test_that("45 degree GLCM metrics", {

  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(hallbey_disc - 1, shift=c(1,1), n_levels= 4), metrics=metrics), read_validation_metrics("hallbey45")[metrics], tolerance = 0.001)
  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(tumor_disc   - 1, shift=c(1,1), n_levels=32), metrics=metrics), read_validation_metrics("tumor45")[metrics],   tolerance = 0.001)
  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(noise_disc   - 1, shift=c(1,1), n_levels=32), metrics=metrics), read_validation_metrics("noise45")[metrics],   tolerance = 0.001)
  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(bars_disc    - 1, shift=c(1,1), n_levels=20), metrics=metrics), read_validation_metrics("bars45")[metrics],    tolerance = 0.001)

})

test_that("90 degree GLCM metrics", {

  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(hallbey_disc - 1, shift=c(0,1), n_levels= 4), metrics=metrics), read_validation_metrics("hallbey90")[metrics], tolerance = 0.001)
  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(tumor_disc   - 1, shift=c(0,1), n_levels=32), metrics=metrics), read_validation_metrics("tumor90")[metrics],   tolerance = 0.001)
  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(noise_disc   - 1, shift=c(0,1), n_levels=32), metrics=metrics), read_validation_metrics("noise90")[metrics],   tolerance = 0.001)
  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(bars_disc    - 1, shift=c(0,1), n_levels=20), metrics=metrics), read_validation_metrics("bars90")[metrics],    tolerance = 0.001)

})

test_that("135 degree GLCM metrics", {

  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(hallbey_disc - 1, shift=c(-1,1), n_levels= 4), metrics=metrics), read_validation_metrics("hallbey135")[metrics], tolerance = 0.001)
  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(tumor_disc   - 1, shift=c(-1,1), n_levels=32), metrics=metrics), read_validation_metrics("tumor135")[metrics],   tolerance = 0.001)
  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(noise_disc   - 1, shift=c(-1,1), n_levels=32), metrics=metrics), read_validation_metrics("noise135")[metrics],   tolerance = 0.001)
  expect_equal(GLCMTextures::glcm_metrics(GLCMTextures::make_glcm(bars_disc    - 1, shift=c(-1,1), n_levels=20), metrics=metrics), read_validation_metrics("bars135")[metrics],    tolerance = 0.001)

})


test_that("Edge cases: all zeroes", {

  # Note that the significance of this test has changed since it was originally written.
  # GLCMTextures treats '0' as an ordinary value, instead of a missing value

  zero <- matrix(0, nrow=3, ncol=3)

  zero_glcm <- GLCMTextures::make_glcm(zero, shift=c(0,1), n_levels = 1)

  expect_equal(zero_glcm, matrix(1))

  expect_true(all(GLCMTextures::glcm_metrics(zero_glcm) %in% list(NaN, 1, 0)))

})



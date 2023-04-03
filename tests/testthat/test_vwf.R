library(ForestTools)

context("Tests for 'vwf'")

### LOAD TEST DATA ----

  chm_test   <- terra::rast("test_data/CHM_test.tif")
  chm_empty  <- terra::rast("test_data/CHM_empty.tif")
  chm_lowres <- terra::rast("test_data/CHM_lowres.tif")
  chm_latlon <- terra::rast("test_data/CHM_latlon.tif")

### PERFORM TESTS ----

  test_that("vwf: expected results using standard parameters", {

    trees_std <- vwf(chm_test, function(x){x * 0.05 + 0.8}, minHeight = 1.5)

    expect_equal(nrow(trees_std), 1115)
    expect_equal(mean(trees_std[["height"]]), 5.857549, tolerance = 0.0000001)
    expect_equal( min(trees_std[["height"]]), 1.503213, tolerance = 0.0000001)
    expect_equal( max(trees_std[["height"]]), 26.89251, tolerance = 0.0000001)
  })


  test_that("vwf: returns an error if 'minHeight' is too high",{

    expect_error(vwf(chm_test, function(x){x * 0.05 + 0.8}, minHeight = 40),
                 "\'minHeight\' is set to a value higher than the highest cell value in 'CHM'")

  })

  test_that("vwf: returns an error if 'CHM' is empty",{

    expect_error(vwf(chm_empty, function(x){x * 0.05 + 0.8}),
                 "Could not compute min/max range of CHM.")
  })

  test_that("vwf: error if window size is too low for a given CHM",{

    err  <- "The map units of the 'CHM' are too small"
    warn <- "Detected coordinate system: 'ellipsoidal'."

    expect_warning(expect_error(vwf(chm_latlon, function(x){x * 0.03 + 0.2}), err), warn)
  })




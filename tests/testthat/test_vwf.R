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
    warn <- "The input CHM has a lat/lon coordinate system. Projected coordinate systems are recommended."

    expect_warning(expect_error(vwf(chm_latlon, function(x){x * 0.03 + 0.2}), err), warn)
  })

  test_that("vwf: produces warnings for lat/lon CRS", {

    win_fun <- function(x){x * 0.05 + 0.8}
    min_hgt <- 1

    # WGS 84 (produces warning)
    chm_4326 <- terra::rast(matrix(3, nrow=10, ncol=10), crs='EPSG:4326')
    expect_warning(vwf(chm_4326, win_fun, min_hgt), "The input CHM has a lat/lon coordinate system.")

    # NAD 83 (produces warning)
    chm_4269 <- terra::rast(matrix(3, nrow=10, ncol=10), crs='EPSG:4269')
    expect_warning(vwf(chm_4269, win_fun, min_hgt), "The input CHM has a lat/lon coordinate system.")

    # WGS 84 with ellipsoidal height (produces warning)
    chm_4979 <- terra::rast(matrix(3, nrow=10, ncol=10), crs='EPSG:4979')
    expect_warning(vwf(chm_4979, win_fun, min_hgt), "The input CHM has a lat/lon coordinate system.")

    # Web Mercator (no warning)
    chm_3857 <- terra::rast(matrix(3, nrow=10, ncol=10), crs='EPSG:3857')
    expect_silent(vwf(chm_3857, win_fun, min_hgt))

    # UTM Zone 33N (no warning)
    chm_32633 <- terra::rast(matrix(3, nrow=10, ncol=10), crs='EPSG:32633')
    expect_silent(vwf(chm_32633, win_fun, min_hgt))

    # NAD83 / UTM Zone 18N (no warning)
    chm_26918 <- terra::rast(matrix(3, nrow=10, ncol=10), crs='EPSG:26918')
    expect_silent(vwf(chm_26918, win_fun, min_hgt))

    # No CRS (no warning)
    chm_nocrs <- terra::rast(matrix(3, nrow=10, ncol=10))
    expect_silent(vwf(chm_nocrs, win_fun, min_hgt))

  })


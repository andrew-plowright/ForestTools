# Load test data


ttops_test <- sf::st_read("test_data/ttops_test.gpkg", quiet=TRUE)
ttops_orphans <- sf::st_read("test_data/ttops_orphans.gpkg", quiet=TRUE)
CHM_test    <- terra::rast("test_data/CHM_test.tif")
CHM_empty   <- terra::rast("test_data/CHM_empty.tif")
CHM_orphans <- terra::rast("test_data/CHM_orphans.tif")





test_that("mcws: expected results using standard parameters", {

  segs_standard <- mcws(ttops_test, CHM_test, minHeight = 1)

  expect_equal(length(unique(segs_standard[])), 1116)
})

test_that("mcws: returns an error if 'minHeight' is too high",{

  expect_error(mcws(ttops_test, CHM_test, minHeight = 30),
               "\'minHeight\' is set higher than the highest cell value in \'CHM\'")
})

test_that("mcws: returns an error if 'CHM' is empty",{

  expect_error(mcws(ttops_test, CHM_empty),
               "'CHM' does not contain any usable values.")
})

test_that("mcws: removes trees outside of CHM area and those that over NA values",{

  # Perform segmentation on 'orphan trees' test dataset
  segs_poly        <- mcws(ttops_orphans, CHM_orphans, format = "polygons")
  segs_ras         <- mcws(ttops_orphans, CHM_orphans, format = "raster")
  segs_poly_min_2m <- mcws(ttops_orphans, CHM_orphans, minHeight = 2, format = "polygons")
  segs_ras_min_2m  <- mcws(ttops_orphans, CHM_orphans, minHeight = 2, format = "raster")

  # Expected behaviour: ttops_vals will equal NaN for any trees outside the range, and NA for NA values inside the range
  # using is.finite filters out both

  ttops_vals    <- terra::extract(CHM_orphans, ttops_orphans)[,2]
  ttops_valid   <- ttops_orphans[is.finite(ttops_vals),]
  ttops_min_2m  <- ttops_orphans[is.finite(ttops_vals) & ttops_vals >= 2,]

  # Count unique segments for raster segments
  segs_ras_unique        <- terra::unique(segs_ras)[,1]
  segs_ras_unique_min_2m <- terra::unique(segs_ras_min_2m)[,1]

  expect_equal(nrow(ttops_valid), nrow(segs_poly))
  expect_equal(nrow(ttops_valid), length(segs_ras_unique))
  expect_equal(nrow(ttops_min_2m), nrow(segs_poly_min_2m))
  expect_equal(nrow(ttops_min_2m), length(segs_ras_unique_min_2m))
})


rm(ttops_test, ttops_orphans, CHM_test, CHM_orphans, CHM_empty)


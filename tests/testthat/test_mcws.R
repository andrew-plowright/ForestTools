context("Tests for 'mcws'")

# Load test data
load("testData/testTrees.Rda")
load("testData/testCHM.Rda")
load("testData/emptyCHM.Rda")
load("testData/orphanCHM.Rda")
load("testData/orphanTrees.Rda")

test_that("mcws: expected results using standard parameters", {

  segs.std <- mcws(testTrees, testCHM, minHeight = 1, verbose = FALSE)

  expect_equal(length(unique(segs.std[])), 1116)
})

test_that("mcws: returns an error if 'minHeight' is too high",{

  expect_error(mcws(testTrees, testCHM, minHeight = 30, verbose = FALSE),
               "\'minHeight\' is set higher than the highest cell value in \'CHM\'")
})

test_that("mcws: returns an error if 'CHM' is empty",{

  expect_error(mcws(testTrees, emptyCHM, verbose = FALSE),
               "Input CHM does not contain any usable values.")
})

test_that("mcws: removes trees outside of CHM area and those that over NA values",{

  # Perform segmentation on 'orphan trees' test dataset
  segs.poly      <- mcws(orphanTrees, orphanCHM, format = "polygons", verbose = FALSE)
  segs.ras       <- mcws(orphanTrees, orphanCHM, verbose = FALSE)
  segs.poly.min2 <- mcws(orphanTrees, orphanCHM, minHeight = 2, format = "polygons", verbose = FALSE)
  segs.ras.min2  <- mcws(orphanTrees, orphanCHM, minHeight = 2, verbose = FALSE)

  # Count number of trees inside of area, that are
  treesOutside <- raster::crop(orphanTrees, orphanCHM)
  treesVals <- raster::extract(orphanCHM, treesOutside)
  treesNoNA <- treesOutside[!is.na(treesVals),]
  treesMin2 <- treesOutside[!is.na(treesVals) & treesVals >= 2,]

  # Count unique segments for raster segments
  segs.ras.unique <- unique(raster::getValues(segs.ras))
  segs.ras.unique <- segs.ras.unique[!is.na(segs.ras.unique)]
  segs.ras.unique.min2 <- unique(raster::getValues(segs.ras.min2))
  segs.ras.unique.min2 <- segs.ras.unique.min2[!is.na(segs.ras.unique.min2)]

  expect_equal(length(treesNoNA), length(segs.poly))
  expect_equal(length(treesNoNA), length(segs.ras.unique))
  expect_equal(length(treesMin2), length(segs.poly.min2))
  expect_equal(length(treesMin2), length(segs.ras.unique.min2))
})



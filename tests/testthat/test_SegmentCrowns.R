library(ForestTools)

context("Tests for SegmentCrowns")

### LOAD TEST DATA

  inCHM <- raster::raster("testFiles\\testCHM\\testCHM.tif")
  emptyCHM <- inCHM
  emptyCHM[] <- NA
  inTiles <- list.files("testFiles\\testCHM\\tiledCHM", full.names = TRUE, pattern = "\\.tif$")
  trees <- rgdal::readOGR("testFiles\\testCHM", "testTrees1", verbose = FALSE)

### PERFORM TESTS

  test_that("SegmentCrown: expected results using standard parameters", {

    segs.std <- SegmentCrowns(trees, inCHM, minHeight = 1)

    expect_equal(length(unique(segs.std[])), 1116)
  })

  test_that("SegmentCrowns: expected results using forced tiling", {

    segs.ftile <- SegmentCrowns(trees, inCHM, minHeight = 1, maxCells = 100000)

    expect_equal(length(unique(segs.ftile[])), 1116)
  })

  test_that("SegmentCrowns: expected results using pre-tiled CHM", {

    segs.ptile <- SegmentCrowns(trees, inTiles, minHeight = 1)

    expect_equal(length(unique(segs.ptile[])), 1116)
  })

  test_that("SegmentCrowns: returns an error if 'minHeight' is too high",{

    err <- "\'minHeight\' is set higher than the highest cell value in \'CHM\'"

    expect_error(SegmentCrowns(trees, inCHM, minHeight = 30), err)
    expect_error(SegmentCrowns(trees, inTiles, minHeight = 30), err)
    expect_error(SegmentCrowns(trees, inCHM, minHeight = 30, maxCells = 100000), err)
  })

  test_that("SegmentCrowns: returns an error if 'CHM' is empty",{

    err <-  "Input CHM does not contain any usable values."

    expect_error(SegmentCrowns(trees, emptyCHM), err)
    expect_error(SegmentCrowns(trees, emptyCHM, minHeight = 30, maxCells = 100000), err)
  })

  test_that("SegmentCrowns: returns an error if no treetops were contained within raster extent",{

    err <- "No input treetops intersect with CHM"

    trees.crop <- raster::crop(trees, raster::raster(inTiles[[1]]))

    expect_error(SegmentCrowns(trees.crop, raster::raster(inTiles[[3]]), minHeight = 1), err)
    expect_error(SegmentCrowns(trees[0,], inCHM), err)
  })





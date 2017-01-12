library(ForestTools)

context("Tests for TreeTopSummary")

### LOAD TEST DATA

  data("kootenayTrees")

  areas.overlap <- rgdal::readOGR("testFiles\\kootenayTests", "areas-overlap", verbose = FALSE)
  areas.partial <- rgdal::readOGR("testFiles\\kootenayTests", "areas-partial", verbose = FALSE)
  areas.outside <- rgdal::readOGR("testFiles\\kootenayTests", "areas-outside", verbose = FALSE)

  grid.small <- raster::raster(raster::extent(kootenayTrees), res = c(2,2), vals = 0, crs = sp::proj4string(kootenayTrees))
  grid.med <- raster::raster(raster::extent(kootenayTrees), res = c(10,10), vals = 0, crs = sp::proj4string(kootenayTrees))
  grid.outside <- raster::raster(raster::extent(5000, 6000, 10000, 11000), res = c(100,100), vals = 0, crs = sp::proj4string(kootenayTrees))

### PERFORM TESTS

  # TESTS WITH INVALID INPUTS

  test_that("TreeTopSummary: Error message with invalid inputs", {

    expect_error(TreeTopSummary(kootenayBlocks, variables = c("height", "radius")), "Invalid input")
    expect_error(TreeTopSummary(kootenayTrees, areas = "this is an error"), "Invalid input")
    expect_error(TreeTopSummary(kootenayTrees, variables = c("height", "nonExistant")),
                 "Invalid input: 'treetops' does not contain variables: 'nonExistant'")

    # Create character attribute
    kootenayTrees[["charVar"]] <- rep(letters, length.out = length(kootenayTrees))

    expect_error(TreeTopSummary(kootenayTrees, variables = c("height", "charVar")),
                 "Invalid input: variables 'charVar' is/are non-numeric")

    expect_error(TreeTopSummary(kootenayTrees, grid = "this is an error"), "Invalid input")
    expect_error(TreeTopSummary(kootenayTrees, areas = kootenayBlocks, grid = 10),
                 "Cannot compute output for both")

  })


  # TESTS WITH NO GRIDS OR AREAS

  test_that("TreeTopSummary: Expected results using no areas or grids", {

      sum.basic <- TreeTopSummary(kootenayTrees, variables = c("height", "radius"))

      expect_equal(sum.basic["TreeCount",], length(kootenayTrees))
      expect_equal(sum.basic["heightMax",], max(kootenayTrees[["height"]]))
      expect_equal(sum.basic["heightMean",], mean(kootenayTrees[["height"]]))
  })


  # TESTS WITH AREAS

  test_that("TreeTopSummary: Expected results using overlapping areas", {

    sum.areaoverlap <- TreeTopSummary(kootenayTrees, variables = "height", areas = areas.overlap)

    expect_equal(sum.areaoverlap@data[1, "TreeCount",], 362)
    expect_equal(sum.areaoverlap@data[1, "heightMax",], 12.60671,tolerance = 0.000001)
    expect_equal(sum.areaoverlap@data[2, "TreeCount",], 199)
  })

  test_that("TreeTopSummary: Expect that area with no treetops returns all NA values", {

    sum.areapartial <- TreeTopSummary(kootenayTrees, variables = "height", areas = areas.partial)

    expect_true(all(is.na(sum.areapartial@data[3, -1])))
  })

  test_that("TreeTopSummary: Expect a warning if no areas contain treetops", {

    expect_warning(
      sum.areaoutside <- TreeTopSummary(kootenayTrees, variables = "height", areas = areas.outside),
                   "No treetops located within given areas")

    expect_true(all(is.na(sum.areaoutside@data[, -1])))
  })

  # Make function to capture points within a given cell
  ptsInCell <- function(pts, ras, cellNum){

    cellCoord <- raster::xyFromCell(ras, cellNum)
    rasRes <- raster::res(ras)
    cellExt <- as(raster::extent(c(cellCoord - rasRes/2, cellCoord + rasRes/2)[c(1,3,2,4)]), "SpatialPolygons")
    sp::proj4string(cellExt) <- sp::proj4string(pts)
    pts[!is.na(sp::over(pts, cellExt)),]
  }


  # TESTS WITH GRIDS

  test_that("TreeTopSummary: Expected results using small grid", {

    sum.sgrid <- TreeTopSummary(kootenayTrees, grid = grid.small, variables = c("height", "radius"))

    # Extract trees overlapping cells with multiple trees
    trees.cell23 <- ptsInCell(kootenayTrees, sum.sgrid, 23)
    trees.cell491 <- ptsInCell(kootenayTrees, sum.sgrid, 491)
    trees.cell2157 <- ptsInCell(kootenayTrees, sum.sgrid, 2157)

    # Check tree count
    expect_equal(length(trees.cell23), 2)
    expect_equal(length(trees.cell491), 2)
    expect_equal(length(trees.cell2157), 2)

    # Check statistics
    expect_equal(as.numeric(sum.sgrid[["heightMean"]][23]),  mean(trees.cell23[["height"]]), tolerance = 0.001)
    expect_equal(as.numeric(sum.sgrid[["radiusMean"]][23]),  mean(trees.cell23[["radius"]]), tolerance = 0.001)

    expect_equal(max(sum.sgrid[["heightMax"]][], na.rm = TRUE), max(kootenayTrees[["height"]]))
    expect_equal(min(sum.sgrid[["heightMin"]][], na.rm = TRUE), min(kootenayTrees[["height"]]))
  })

  test_that("TreeTopSummary: Expected results using med grid", {

    sum.mgrid <- TreeTopSummary(kootenayTrees, grid = grid.med, variables = c("height", "radius"))

    # Extract trees overlapping cells with multiple trees
    trees.cell13 <- ptsInCell(kootenayTrees, sum.mgrid, 13)
    trees.cell42 <- ptsInCell(kootenayTrees, sum.mgrid, 42)
    trees.cell126 <- ptsInCell(kootenayTrees, sum.mgrid, 126)

    # Check tree count
    expect_equal(length(trees.cell13), 15)
    expect_equal(length(trees.cell42), 12)
    expect_equal(length(trees.cell126), 11)

    # Check statistics
    expect_equal(as.numeric(sum.mgrid[["heightMean"]][42]),  mean(trees.cell42[["height"]]), tolerance = 0.001)
    expect_equal(as.numeric(sum.mgrid[["radiusMean"]][42]),  mean(trees.cell42[["radius"]]), tolerance = 0.001)

    expect_equal(max(sum.mgrid[["heightMax"]][], na.rm = TRUE), max(kootenayTrees[["height"]]))
    expect_equal(min(sum.mgrid[["heightMin"]][], na.rm = TRUE), min(kootenayTrees[["height"]]))
  })

  test_that("TreeTopSummary: Expected results using a grid defined by numerical interval", {

    sum.intgrid <- TreeTopSummary(kootenayTrees, grid = 100, variables = c("height", "radius"))

    expect_equal(as.numeric(sum.intgrid[["TreeCount"]][2,2]), 27)

  })

  test_that("TreeTopSummary: Warning message if input grid does not overlap with trees", {

    expect_warning(
      sum.gridoutside <- TreeTopSummary(kootenayTrees, grid = grid.outside, variables = c("height", "radius")),
      "No treetops located within given grid")

    expect_true(all(is.na(sum.gridoutside[])))
  })

  #######################################################################

  # which(sum.lgrid[["TreeCount"]][] > 10)
  #
  # raster::writeRaster(sum.intgrid[["TreeCount"]], "C:\\Users\\Andy\\Desktop\\DEL\\intgrid-count.tif", overwrite = TRUE)
  # raster::writeRaster(sum.lgrid[["heightMax"]], "C:\\Users\\Andy\\Desktop\\DEL\\lgrid-hgtmax.tif")
  # rgdal::writeOGR(sum.areaoverlap, "C:\\Users\\Percival\\Desktop\\DEL", "sumoverlap", driver = "ESRI Shapefile")



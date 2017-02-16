library(ForestTools)

context("Tests for SpatialStatistics")

### LOAD TEST DATA

  data("kootenayTrees")
  data("kootenayCrowns")

  load("areas-overlap.Rda")
  load("areas-outside.Rda")
  load("areas-partial.Rda")

  grid.small <- raster::raster(raster::extent(kootenayTrees), res = c(2,2), vals = 0, crs = sp::proj4string(kootenayTrees))
  grid.med <- raster::raster(raster::extent(kootenayTrees), res = c(10,10), vals = 0, crs = sp::proj4string(kootenayTrees))
  grid.outside <- raster::raster(raster::extent(5000, 6000, 10000, 11000), res = c(100,100), vals = 0, crs = sp::proj4string(kootenayTrees))


### TESTS WITH INVALID INPUTS

  test_that("SpatialStatistics: Error message with invalid inputs", {

    # Invalid input for 'trees'
    expect_error(SpatialStatistics("this is an error", variables = c("height", "winRadius")),
                 "Invalid input: 'trees' must be a SpatialPointsDataFrame or SpatialPolygonsDataFrame")

    # Invalid input for 'areas'
    expect_error(SpatialStatistics(kootenayTrees, areas = "this is an error"),
                 "Invalid input: 'areas' must be a SpatialPolygonsDataframe object")

    # Invalid input for 'variables': variable doesn't exist
    expect_error(SpatialStatistics(kootenayTrees, variables = c("height", "this is an error")),
                 "Invalid input: 'trees' does not contain variables: 'this is an error'")

    # Invalid input for 'variables': variable is non-numeric
    kootenayTrees[["charVar"]] <- rep(letters, length.out = length(kootenayTrees))
    expect_error(SpatialStatistics(kootenayTrees, variables = c("height", "charVar")),
                 "Invalid input: variables 'charVar' is/are non-numeric")

    # Invalid input for 'grid'
    expect_error(SpatialStatistics(kootenayTrees, grid = "this is an error"), "Invalid input")

    # Both 'grid' and 'areas' are simultaneously defined
    expect_error(SpatialStatistics(kootenayTrees, areas = kootenayBlocks, grid = 10),
                 "Cannot compute output for both")
  })


### TESTS WITH NO GRIDS OR AREAS

  test_that("SpatialStatistics: Expected results using no areas or grids", {

      sum.basic.pts <- SpatialStatistics(kootenayTrees, variables = c("height", "winRadius"))
      sum.basic.poly <- SpatialStatistics(kootenayCrowns, variables = c("height", "crownArea"))

      # Statistics are equal to those calculated outside of the function
      expect_equal(sum.basic.pts["TreeCount",], length(kootenayTrees))
      expect_equal(sum.basic.pts["heightMax",], max(kootenayTrees[["height"]]))
      expect_equal(sum.basic.pts["heightMean",], mean(kootenayTrees[["height"]]))

      # Statistics are equal for when 'trees' are both points and crowns
      expect_equal(sum.basic.pts["TreeCount",], sum.basic.poly["TreeCount",])
      expect_equal(sum.basic.pts["heightMax",], sum.basic.poly["heightMax",])
      expect_equal(sum.basic.pts["heightMean",], sum.basic.poly["heightMean",])
  })

### TESTS WITH AREAS

  test_that("SpatialStatistics: Expected results using overlapping areas", {

    # With trees
    sum.areaoverlap.pts <- SpatialStatistics(kootenayTrees, variables = "height", areas = areas.overlap)

    expect_equal(sum.areaoverlap.pts@data[1, "TreeCount",], 362)
    expect_equal(sum.areaoverlap.pts@data[1, "heightMax",], 12.60671, tolerance = 0.000001)
    expect_equal(sum.areaoverlap.pts@data[2, "TreeCount",], 199)

    # With crowns
    sum.areaoverlap.crowns <- SpatialStatistics(kootenayCrowns, variables = c("crownArea", "height"), areas = areas.overlap)

    expect_equal(sum.areaoverlap.crowns@data[1, "TreeCount",], 362)
    expect_equal(sum.areaoverlap.crowns@data[1, "crownAreaMean",], 6.801105, tolerance = 0.000001)
    expect_equal(sum.areaoverlap.crowns@data[2, "TreeCount",], 200)

    # Both crowns and treetops return the same result for a polygon that captures the same trees
    expect_equal(sum.areaoverlap.crowns[["heightMax"]][1], sum.areaoverlap.pts[["heightMax"]][1])

  })

  test_that("SpatialStatistics: Expect that area with no treetops returns all NA values", {

    sum.areapartial.pts <- SpatialStatistics(kootenayTrees, variables = "height", areas = areas.partial)

    expect_true(all(is.na(sum.areapartial.pts@data[3, -1])))

    sum.areapartial.crowns <- SpatialStatistics(kootenayCrowns, variables = "height", areas = areas.partial)

    expect_true(all(is.na(sum.areapartial.crowns@data[3, -1])))

  })

  test_that("SpatialStatistics: Expect a warning if no areas contain treetops", {

    expect_warning(
      sum.areaoutside.pts <- SpatialStatistics(kootenayTrees, variables = "height", areas = areas.outside),
                   "No trees located within given areas")

    expect_true(all(is.na(sum.areaoutside.pts@data[, -1])))


    expect_warning(
      sum.areaoutside.crowns <- SpatialStatistics(kootenayCrowns, variables = "height", areas = areas.outside),
      "No trees located within given areas")

    expect_true(all(is.na(sum.areaoutside.crowns@data[, -1])))
  })

### TESTS WITH GRIDS

  # Make function to capture points within a given cell
  ptsInCell <- function(pts, ras, cellNum){

    cellCoord <- raster::xyFromCell(ras, cellNum)
    rasRes <- raster::res(ras)
    cellExt <- as(raster::extent(c(cellCoord - rasRes/2, cellCoord + rasRes/2)[c(1,3,2,4)]), "SpatialPolygons")
    sp::proj4string(cellExt) <- sp::proj4string(pts)
    pts[!is.na(sp::over(rgeos::gCentroid(pts, byid = TRUE), cellExt)),]
  }

  test_that("SpatialStatistics: Expected results using small grid", {

    sum.sgrid.pts <- SpatialStatistics(kootenayTrees, grid = grid.small, variables = c("height", "winRadius"))

    # Extract trees overlapping cells with multiple trees
    trees.cell23 <- ptsInCell(kootenayTrees, sum.sgrid.pts, 23)
    trees.cell491 <- ptsInCell(kootenayTrees, sum.sgrid.pts, 491)
    trees.cell2157 <- ptsInCell(kootenayTrees, sum.sgrid.pts, 2157)

    # Check tree count
    expect_equal(length(trees.cell23), 2)
    expect_equal(length(trees.cell491), 2)
    expect_equal(length(trees.cell2157), 2)

    # Check statistics
    expect_equal(as.numeric(sum.sgrid.pts[["heightMean"]][23]),  mean(trees.cell23[["height"]]), tolerance = 0.001)
    expect_equal(as.numeric(sum.sgrid.pts[["winRadiusMean"]][23]),  mean(trees.cell23[["winRadius"]]), tolerance = 0.001)

    expect_equal(max(sum.sgrid.pts[["heightMax"]][], na.rm = TRUE), max(kootenayTrees[["height"]]))
    expect_equal(min(sum.sgrid.pts[["heightMin"]][], na.rm = TRUE), min(kootenayTrees[["height"]]))

  })

  test_that("SpatialStatistics: Expected results using med grid", {

    sum.mgrid <- SpatialStatistics(kootenayTrees, grid = grid.med, variables = c("height", "winRadius"))

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
    expect_equal(as.numeric(sum.mgrid[["winRadiusMean"]][42]),  mean(trees.cell42[["winRadius"]]), tolerance = 0.001)

    expect_equal(max(sum.mgrid[["heightMax"]][], na.rm = TRUE), max(kootenayTrees[["height"]]))
    expect_equal(min(sum.mgrid[["heightMin"]][], na.rm = TRUE), min(kootenayTrees[["height"]]))
  })

  test_that("SpatialStatistics: Expected results using a grid defined by numerical interval", {

    sum.intgrid <- SpatialStatistics(kootenayTrees, grid = 100, variables = c("height", "winRadius"))

    expect_equal(as.numeric(sum.intgrid[["TreeCount"]][2,2]), 27)

  })

  test_that("SpatialStatistics: Warning message if input grid does not overlap with trees", {

    expect_warning(
      sum.gridoutside <- SpatialStatistics(kootenayTrees, grid = grid.outside, variables = c("height", "winRadius")),
      "No trees located within given grid")

    expect_true(all(is.na(sum.gridoutside[])))
  })

### TEST WITH CUSTOM METRICS

  test_that("SpatialStatistics: Custom functions meeting conditions work properly",{

    # Create custom functions
    cust.mean <- function(x, ...) sum(x) / length(x)
    cust.qunt <- function(x, ...) quantile(x, c(.98), na.rm = TRUE)

    cust.statFuns <- list(mean = mean, custMean = cust.mean, custQunt = cust.qunt)

    # Using grid, all values from the 'mean' and 'custom mean' functions should be the same
    sum.custfun.gridmed <- SpatialStatistics(kootenayTrees, variables = c("height", "winRadius"), grid = grid.med, statFuns = cust.statFuns)
    expect_true(all.equal(raster::getValues(sum.custfun.gridmed[["heightmean"]]),
                          raster::getValues(sum.custfun.gridmed[["heightcustMean"]])))

    # Using area, all values from the 'mean' and 'custom mean' functions should be the same
    sum.custfun.areaspartial <- SpatialStatistics(kootenayTrees, variables = c("height", "winRadius"), areas = areas.partial, statFuns = cust.statFuns)
    expect_true(all.equal(sum.custfun.areaspartial[["heightmean"]],
                          sum.custfun.areaspartial[["heightcustMean"]]))

    # Get a warning if grid is outside of area
    expect_warning(
      sum.custfun.gridout <- SpatialStatistics(kootenayTrees, variables = c("height", "winRadius"), grid = grid.outside, statFuns = cust.statFuns),
      "No trees located within given grid")
    expect_warning(
      sum.custfun.areasout <- SpatialStatistics(kootenayTrees, variables = c("height", "winRadius"), areas = areas.outside, statFuns = cust.statFuns),
      "No trees located within given areas")
  })

  test_that("SpatialStatistics: Custom functions meeting conditions work properly",{

    fail1 <- list(fail1 = function(x,y, ...) x + y)
    fail2 <- list(fail2 = function(x) sum(x) / length(x))
    fail3 <- list(fail3 = function(x, ...) c(x[1], x[3]))
    fail4 <- list(function(x,...) length(x))
    fail5 <- list(fail5 = function(x, ...) as.character(x))

    # Fail 1: Function's input is (x, y, ...) instead of just (x, ...)
    expect_error(SpatialStatistics(kootenayTrees, statFuns = fail1, variables = c("height", "winRadius"), grid = grid.med),
                 "The 'fail1' function's arguments should be: function")

    # Fail 2: Function's input is (x) instead of just (x, ...)
    expect_error(SpatialStatistics(kootenayTrees, statFuns = fail2, variables = c("height", "winRadius"), grid = grid.med),
                 "The 'fail2' function's arguments should be: function")

    # Fail 3: Function returns more than a single value
    expect_error(SpatialStatistics(kootenayTrees, statFuns = fail3, variables = c("height", "winRadius"), grid = grid.med),
                "The 'fail3' function cannot be used.\nReasons:\n1. Returned more than a single value")

    # Fail 4: List of functions should be named
    expect_error(SpatialStatistics(kootenayTrees, statFuns = fail4, variables = c("height", "winRadius"), grid = grid.med),
                "List of functions for 'statFuns' must be named")

    # Fail 5: Function returns a character
    expect_error(SpatialStatistics(kootenayTrees, statFuns = fail5, variables = c("height", "winRadius"), grid = grid.med),
                 "The 'fail5' function cannot be used.\nReasons:\n1. Returned value was neither logical or numeric")
  })

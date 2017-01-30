### LOAD TEST AREA

  # Load CHM for test area
  testCHM <- raster::raster("testdata-raw\\testCHM\\testCHM.tif") + 0
  emptyCHM <- setValues(testCHM, NA)

  # Load CHM as a series of tiles
  testCHM.tiles <- list.files("testdata-raw\\testCHM\\tiledCHM", full.names = TRUE, pattern = "\\.tif$")
  testCHM.tiles <- lapply(testCHM.tiles, function(tilePath) raster(tilePath) + 0)

  # Load trees for test area
  testTrees <- rgdal::readOGR("testdata-raw\\testCHM", "testTrees1", verbose = FALSE)

### CREATE OPHAN SEGMENT TEST DATA

  # Crop test CHM
  par(mar = rep(0,4))
  orphanCHM <- testCHM
  orphanCHM[orphanCHM < 1.5] <- NA
  plot(orphanCHM)
  orphanCHM <- crop(orphanCHM, drawExtent())

  # Subset test trees
  orphantrees <- crop(testTrees, extent(orphanCHM) + 5)

  # Add some extra trees in NA zones
  addtrees <- click(orphanCHM, xy = TRUE, 2)
  addtrees <- SpatialPoints(addtrees[,1:2], proj4string = crs(testTrees) )
  row.names(orphantrees) <- 1:length(orphantrees)
  row.names(addtrees) <- (length(orphantrees) + 1):(length(orphantrees) + length(addtrees))
  orphantrees <- maptools::spRbind(orphantrees, addtrees)
  orphantrees <- SpatialPointsDataFrame(orphantrees, data.frame(nodata = rep(NA, length(orphantrees))))

### LOAD POLYGONS FOR TREETOP SUMMARY TESTS

  areas.overlap <- rgdal::readOGR("testdata-raw\\kootenayTests", "areas-overlap", verbose = FALSE)
  areas.partial <- rgdal::readOGR("testdata-raw\\kootenayTests", "areas-partial", verbose = FALSE)
  areas.outside <- rgdal::readOGR("testdata-raw\\kootenayTests", "areas-outside", verbose = FALSE)

### SAVE DATA

  save(testTrees, file = "tests\\testthat\\testTrees.Rda")
  save(testCHM.tiles, file = "tests\\testthat\\testCHMtiles.Rda")
  save(testCHM, file = "tests\\testthat\\testCHM.Rda")
  save(emptyCHM, file = "tests\\testthat\\emptyCHM.Rda")

  save(orphanCHM, file = "tests\\testthat\\orphanCHM.Rda")
  save(orphantrees, file = "tests\\testthat\\orphantrees.Rda")

  save(areas.overlap, file = "tests\\testthat\\areas-overlap.Rda")
  save(areas.partial, file = "tests\\testthat\\areas-partial.Rda")
  save(areas.outside, file = "tests\\testthat\\areas-outside.Rda")

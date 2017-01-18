# Load files

inCHM <- raster::raster("tests\\testthat\\testdata\\testCHM\\testCHM.tif") + 0
emptyCHM <- setValues(inCHM, NA)

inTiles <- list.files("tests\\testthat\\testdata\\testCHM\\tiledCHM", full.names = TRUE, pattern = "\\.tif$")
inTiles <- lapply(inTiles, function(tilePath) raster(tilePath) + 0)

trees <- rgdal::readOGR("tests\\testthat\\testdata\\testCHM", "testTrees1", verbose = FALSE)

areas.overlap <- rgdal::readOGR("tests\\testthat\\testdata\\kootenayTests", "areas-overlap", verbose = FALSE)
areas.partial <- rgdal::readOGR("tests\\testthat\\testdata\\kootenayTests", "areas-partial", verbose = FALSE)
areas.outside <- rgdal::readOGR("tests\\testthat\\testdata\\kootenayTests", "areas-outside", verbose = FALSE)

# Save data files

save(trees, file = "tests\\testthat\\testdata\\trees.Rda")
save(inTiles, file = "tests\\testthat\\testdata\\inTiles.Rda")
save(inCHM, file = "tests\\testthat\\testdata\\inCHM.Rda")
save(emptyCHM, file = "tests\\testthat\\testdata\\emptyCHM.Rda")
save(areas.overlap, file = "tests\\testthat\\testdata\\areas-overlap.Rda")
save(areas.partial, file = "tests\\testthat\\testdata\\areas-partial.Rda")
save(areas.outside, file = "tests\\testthat\\testdata\\areas-outside.Rda")

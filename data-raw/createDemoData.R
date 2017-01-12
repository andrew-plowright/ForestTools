### CHM DEMO

  # Load full-size canopy height model (CHM)
  CHM <- raster::raster("C:\\Users\\Percival\\Desktop\\SpireTemp\\Block375\\UAVSurvey_2016-06-16\\ForestAnalysis\\CHM\\CHM_Block375.asc")

  # Plot CHM
  old <- par()$mar
  par(mar = rep(0,4))
  raster::plot(CHM)
  par(mar = old)

  # Crop CHM demo
  CHMdemo <- raster::crop(CHM, raster::drawExtent())

  # Write CHM to raw data folder
  raster::writeRaster(CHMdemo, "data-raw\\CHMdemo.tif")

  # Save data to package
  devtools::use_data(CHMdemo)

### KOOTENAY DATASET

  # Load full-size canopy height model (CHM)
  rawCHM <- raster::raster("C:\\Users\\Percival\\Desktop\\SpireTemp\\Block430\\UAVSurvey_2016-06-15\\ForestAnalysis\\CHM\\CHM_Block430.asc")

  # Plot CHM
  old <- par()$mar
  par(mar = rep(0,4))
  raster::plot(rawCHM)
  par(mar = old)

  # Crop CHM demo
  kootenayCHM.crop <- raster::crop(rawCHM, raster::drawExtent())

  # Downsample raster
  kootenayCHM <- raster::aggregate(kootenayCHM.crop, factor = 2, fun= mean)

  # Write CHM to raw data folder
  raster::writeRaster(kootenayCHM, "data-raw\\kootenayCHM.tif")

  # Load Kootenany areas
  kootenayBlocks <- rgdal::readOGR("C:\\Users\\Percival\\Dropbox\\Scripts\\Libraries\\ForestTools\\data-raw" ,"kootenayBlocks")

  # Detect trees
  kootenayTrees <- ForestTools::TreeTopFinder(kootenayCHM, function(x){x * 0.07 + 0.8}, 2)
  rgdal::writeOGR(kootenayTrees, "C:\\Users\\Percival\\Dropbox\\Scripts\\Libraries\\ForestTools\\data-raw", "kootenayTrees", driver = "ESRI Shapefile")

  # Plot data
  par(mar = rep(0,4))
  raster::plot(kootenayCHM)
  sp::plot(kootenayBlocks, add = T)
  sp::plot(kootenayTrees, add = T, pch = ".", cex = 2)

  # Save data to package
  devtools::use_data(kootenayCHM, kootenayBlocks, kootenayTrees)

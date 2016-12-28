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

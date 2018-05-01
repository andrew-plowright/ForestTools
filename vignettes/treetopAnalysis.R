## ----global_options, include=FALSE, dpi =  300---------------------------
knitr::opts_knit$set(global.par = TRUE)

## ---- eval = FALSE-------------------------------------------------------
#  install.packages("installr")
#  library(installr)
#  updateR()

## ---- eval = FALSE-------------------------------------------------------
#  install.packages("ForestTools")

## ---- message = FALSE----------------------------------------------------
# Attach the 'ForestTools' and 'raster' libraries
library(ForestTools)
library(raster)

# Load sample canopy height model
data("kootenayCHM")

## ---- fig.width = 4, fig.height = 2.51-----------------------------------
# Remove plot margins (optional)
par(mar = rep(0.5, 4))

# Plot CHM (extra optional arguments remove labels and tick marks from the plot)
plot(kootenayCHM, xlab = "", ylab = "", xaxt='n', yaxt = 'n')

## ------------------------------------------------------------------------
lin <- function(x){x * 0.05 + 0.6}

## ------------------------------------------------------------------------
ttops <- vwf(CHM = kootenayCHM, winFun = lin, minHeight = 2)

## ---- fig.width = 4, fig.height = 2.51-----------------------------------
# Plot CHM
plot(kootenayCHM, xlab = "", ylab = "", xaxt='n', yaxt = 'n')

# Add dominant treetops to the plot
plot(ttops, col = "blue", pch = 20, cex = 0.5, add = TRUE)


## ------------------------------------------------------------------------
# Get the mean treetop height
mean(ttops$height)

## ---- fig.width = 4, fig.height = 2.51-----------------------------------
# Create crown map
crowns <- mcws(treetops = ttops, CHM = kootenayCHM, minHeight = 1.5, verbose = FALSE)

# Plot crowns
plot(crowns, col = sample(rainbow(50), length(unique(crowns[])), replace = TRUE), legend = FALSE, xlab = "", ylab = "", xaxt='n', yaxt = 'n')

## ---- fig.width = 4, fig.height = 2.51-----------------------------------
# Create polygon crown map
crownsPoly <- mcws(treetops = ttops, CHM = kootenayCHM, format = "polygons", minHeight = 1.5, verbose = FALSE)

# Plot CHM
plot(kootenayCHM, xlab = "", ylab = "", xaxt='n', yaxt = 'n')

# Add crown outlines to the plot
plot(crownsPoly, border = "blue", lwd = 0.5, add = TRUE)

## ------------------------------------------------------------------------
# Compute average crown diameter
crownsPoly[["crownDiameter"]] <- sqrt(crownsPoly[["crownArea"]]/ pi) * 2

# Mean crown diameter
mean(crownsPoly$crownDiameter)

## ------------------------------------------------------------------------
sp_summarise(ttops)

## ------------------------------------------------------------------------
sp_summarise(crownsPoly, variables = c("crownArea", "height"))

## ---- fig.width = 4, fig.height = 2.51, message = FALSE------------------
data("kootenayBlocks")

# Compute tree count and height statistics for cut blocks
blockStats <- sp_summarise(ttops, areas = kootenayBlocks, variables = "height")

# Plot CHM
plot(kootenayCHM, xlab = "", ylab = "", xaxt='n', yaxt = 'n')

# Add block outlines to the plot
plot(kootenayBlocks, add = TRUE, border =  "darkmagenta", lwd = 2)

# Add tree counts to the plot
library(rgeos)
text(gCentroid(kootenayBlocks, byid = TRUE), blockStats[["TreeCount"]], col = "darkmagenta", font = 2)

# View height statistics
blockStats@data

## ---- fig.width = 4, fig.height = 2.51-----------------------------------
# Compute tree count within a 10 m x 10 m cell grid
gridCount <- sp_summarise(ttops, grid = 10)

# Plot grid
plot(gridCount, col = heat.colors(255), xlab = "", ylab = "", xaxt='n', yaxt = 'n')

## ------------------------------------------------------------------------
# Compute tree height statistics within a 10 m x 10 m cell grid
gridStats <- sp_summarise(trees = ttops, grid = 10, variables = "height")

# View layer names
names(gridStats)

## ---- fig.width = 4, fig.height = 2.51-----------------------------------
# Plot mean tree height within 10 m x 10 m cell grid
plot(gridStats[["heightMean"]], col = heat.colors(255), xlab = "", ylab = "", xaxt='n', yaxt = 'n')

## ------------------------------------------------------------------------
quant98 <- function(x, ...) quantile(x, c(.98), na.rm = TRUE)

## ------------------------------------------------------------------------
# Create list of functions
custFuns <- list(quant98, max)
names(custFuns) <- c("98thQuantile", "Max")

# Generate statistics for crown areas and tree heights
sp_summarise(crownsPoly, variables = c("crownArea", "height"), statFuns = custFuns)


## ---- echo = FALSE-------------------------------------------------------
forestData <- data.frame(
  c("Canopy height model", "Treetops", "Crown outlines", "Gridded statistics"),
  c("Single-layer raster", "Points", "Polygons", "Multi-layer raster"),
  c("[RasterLayer](https://cran.r-project.org/package=raster/raster.pdf#page=159)", 
    "[SpatialPointsDataFrame](https://cran.r-project.org/package=sp/sp.pdf#page=84)", 
    "[RasterLayer](https://cran.r-project.org/package=raster/raster.pdf#page=159), [SpatialPolygonsDataFrame](https://cran.r-project.org/package=sp/sp.pdf#page=89)", 
    "[RasterLayer](https://cran.r-project.org/package=raster/raster.pdf#page=159),  [RasterBrick](https://cran.r-project.org/package=raster/raster.pdf#page=159)")
)
names(forestData) <- c("Data product", "Data type", "Object class")
knitr::kable(forestData)

## ---- eval = FALSE-------------------------------------------------------
#  library(raster)
#  
#  # Load a canopy height model
#  inCHM <- raster("C:\\myFiles\\inputs\\testCHM.tif")

## ---- eval = FALSE-------------------------------------------------------
#  # Write a crown map raster file
#  writeRaster(crowns, "C:\\myFiles\\outputs\\crowns.tif", dataType = "INT2U")

## ---- eval = FALSE-------------------------------------------------------
#  library(rgdal)
#  
#  # Load the 'block375.shp' file
#  blk375boundary <- readOGR("C:\\myFiles\\blockBoundaries", "block375")
#  

## ---- eval = FALSE-------------------------------------------------------
#  # Save a set of dominant treetops
#  writeOGR(ttops, "C:\\myFiles\\outputs", "treetops", driver = "ESRI Shapefile")
#  


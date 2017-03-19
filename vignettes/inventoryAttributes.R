## ----global_options, include=FALSE, dpi =  300---------------------------
knitr::opts_knit$set(global.par = TRUE)

## ---- message = FALSE----------------------------------------------------
# Attach the 'ForestTools' and 'raster' libraries
library(ForestTools)
library(raster)

# Load sample canopy height model, treetops and block boundaries
data("quesnelCHM", "quesnelTrees", "quesnelBlocks")

## ---- fig.width = 4, fig.height = 2.51-----------------------------------
# Remove plot margins (optional)
par(mar = rep(0.5, 4))

# Plot CHM and blocks (extra optional arguments remove labels and tick marks from the plot)
plot(quesnelCHM, xlab = "", ylab = "", xaxt='n', yaxt = 'n')
plot(quesnelBlocks, add = TRUE, border =  "darkmagenta", lwd = 2)

## ------------------------------------------------------------------------
# Create custom function for computing top height
topHgtFun <- function(x, ...) mean(tail(sort(x), 100))

## ------------------------------------------------------------------------
# Use SpatialStatistics to generate gridded statistics
sptStatRas <- SpatialStatistics(quesnelTrees, variables = "height", grid = 100, statFuns = list(Top100 = topHgtFun))

# View information about the result
sptStatRas

## ---- fig.width = 4, fig.height = 2.51-----------------------------------
# Subset top height raster
topHgtRas <- sptStatRas[["heightTop100"]]

# View top height on a 1 ha grid
plot(topHgtRas, xlab = "", ylab = "", xaxt='n', yaxt = 'n')

## ---- fig.width = 4, fig.height = 2.51-----------------------------------
# Rasterize block boundaries
blockRas <- rasterize(quesnelBlocks, topHgtRas)

# View results
plot(blockRas, xlab = "", ylab = "", xaxt='n', yaxt = 'n')

# Use rasterized block boundaries to compute zonal statistics
zoneStat <- zonal(topHgtRas, blockRas, 'mean')
zoneStat

## ---- fig.width = 4, fig.height = 2.51, message = FALSE------------------
# Create new 'topHeight' attribute from zonal statistics
quesnelBlocks[["topHeight"]] <- zoneStat[,"mean"]

# Plot result
library(rgeos)
colRamp <- colorRampPalette(c('lightgoldenrod1', 'tomato2'))(10)
cols <- colRamp[as.numeric(cut(quesnelBlocks[["topHeight"]],breaks = 10))]
plot(quesnelBlocks, col = cols, xlab = "", ylab = "", xaxt='n', yaxt = 'n')
text(gCentroid(quesnelBlocks, byid = TRUE), round(quesnelBlocks[["topHeight"]],2), font = 2)


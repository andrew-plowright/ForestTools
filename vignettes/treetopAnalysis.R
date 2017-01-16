## ----global_options, include=FALSE, dpi =  300---------------------------
knitr::opts_knit$set(global.par = TRUE)

## ---- eval = FALSE-------------------------------------------------------
#  install.packages("installr")
#  library(installr)
#  updateR()

## ---- eval = FALSE-------------------------------------------------------
#  install.packages("ForestTools")

## ---- message = FALSE----------------------------------------------------
# Attach the Forest Tools and raster libraries
library(ForestTools)
library(raster)

# Load sample data
data("kootenayCHM")

## ---- fig.width = 4, fig.height = 2.51-----------------------------------
# Remove plot margins (optional)
par(mar = rep(0.5, 4))

# Plot CHM (extra optional arguments remove labels and tick marks from the plot)
plot(kootenayCHM, xlab = "", ylab = "", xaxt='n', yaxt = 'n')

## ------------------------------------------------------------------------
lin <- function(x){x * 0.05 + 0.6}

## ------------------------------------------------------------------------
ttops <- TreeTopFinder(CHM = kootenayCHM, winFun = lin, minHeight = 2)

## ---- fig.width = 4, fig.height = 2.51-----------------------------------
# Plot CHM
plot(kootenayCHM, xlab = "", ylab = "", xaxt='n', yaxt = 'n')

# Plot treetops
plot(ttops, col = "blue", pch = 20, cex = 0.5, add = TRUE)


## ------------------------------------------------------------------------
# Get the mean treetop height
mean(ttops$height)

## ------------------------------------------------------------------------
TreeTopSummary(ttops)

## ------------------------------------------------------------------------
TreeTopSummary(ttops, variables = "height")

## ---- fig.width = 4, fig.height = 2.51, message = FALSE------------------
data("kootenayBlocks")

# Compute tree count and height statistics for cut blocks
blockStats <- TreeTopSummary(ttops, areas = kootenayBlocks, variables = "height")

# Plot CHM
plot(kootenayCHM, xlab = "", ylab = "", xaxt='n', yaxt = 'n')

# Plot blocks
plot(kootenayBlocks, add = TRUE, border =  "darkmagenta", lwd = 2)

# Add tree counts to plot
library(rgeos)
text(gCentroid(kootenayBlocks, byid = TRUE), blockStats[["TreeCount"]], col = "darkmagenta", font = 2)

# View height statistics
blockStats@data

## ---- fig.width = 4, fig.height = 2.51-----------------------------------
crowns <- SegmentCrowns(treetops = ttops, CHM = kootenayCHM, minHeight = 1.5)

# Plot crowns
plot(crowns, col = sample(rainbow(50), length(crowns), replace = TRUE), legend = FALSE, , xlab = "", ylab = "", xaxt='n', yaxt = 'n')

## ---- fig.width = 4, fig.height = 2.51-----------------------------------
# Convert raster crown map to polygons
crownsPoly <- rasterToPolygons(crowns, dissolve = TRUE)

# Plot CHM
plot(kootenayCHM, xlab = "", ylab = "", xaxt='n', yaxt = 'n')

# Plot crown outlines
plot(crownsPoly, border = "blue", lwd = 0.5, add = TRUE)

## ---- message = FALSE----------------------------------------------------
library(rgeos)

# Compute crown area
crownsPoly[["area"]] <- gArea(crownsPoly, byid = TRUE)

## ------------------------------------------------------------------------
crownsPoly[["diameter"]] <- sqrt(crownsPoly[["area"]]/ pi) * 2

# Mean crown diameter
mean(crownsPoly$diameter)


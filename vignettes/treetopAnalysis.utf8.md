---
title: "Canopy analysis in R using Forest Tools"
author: "Andrew Plowright"
date: "2017-01-21"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Canopy analysis}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---


## Introduction

The Forest Tools R package offers functions to analyze remotely sensed forest data. Currently, tools to detect dominant treetops and outline tree crowns have been implemented, both of which are applied to a rasterized **canopy height model (CHM)**, which is generally derived from LiDAR or photogrammetric point clouds. A function to summarize the height and count of treetops within user-defined geographical areas is also available.

The following vignette provides examples for using these functions.

## Installation

Check that R is up-to-date. This can be done automatically using the `installr` package.


```r
install.packages("installr")
library(installr)
updateR()
```

Download and install the Forest Tools package from CRAN (the Comprehensive R Archive Network)
using the `install.packages` function.


```r
install.packages("ForestTools")
```

## Loading sample data

A sample CHM is included in the Forest Tools package. It represents a small 1.5 hectare swath of forest in the Kootenay Mountains, British Columbia. The following examples use this sample, but if you would rather use your own data, it can be loaded into R using the `raster` function. A brief section on [reading and writing geospatial data in R](#readsave) is included in this document. Otherwise, begin by loading the necessary libraries and the sample CHM using the `library` and `data` functions respectively.


```r
# Attach the Forest Tools and raster libraries
library(ForestTools)
library(raster)

# Load sample data
data("kootenayCHM")
```

View the CHM using the `plot` function. The cell values are equal to the canopy's height above ground.


```r
# Remove plot margins (optional)
par(mar = rep(0.5, 4))

# Plot CHM (extra optional arguments remove labels and tick marks from the plot)
plot(kootenayCHM, xlab = "", ylab = "", xaxt='n', yaxt = 'n')
```

![](treetopAnalysis_files/figure-html/unnamed-chunk-4-1.png)<!-- -->

## Detecting treetops

Dominant treetops can be detected using `TreeTopFinder`. This function implements the _variable window filter_ algorithm developped by Popescu and Wynne (2004). In short, a moving window scans the CHM, and if a given cell is found to be the highest within the window, it is tagged as a treetop. The size of the window itself changes depending on the height of the cell on which it is centered. This is to compensate for varying crown sizes, with tall trees having wide crowns and vice versa.

Therefore, the first step is to define the **function that will define the dynamic window size**. Essentially, this function should take a **CHM cell value** (i.e.: the height of the canopy above ground at that location) and return the **radius of the search window**. Here, we will define a simple linear equation, but any function with a single input and output will work.


```r
lin <- function(x){x * 0.05 + 0.6}
```
We do not wish for the `TreeTopFinder` to tag low-lying underbrush or other spurious treetops, and so we also set a minimum height of 2 m using the `minHeight` argument. Any cell with a lower value will not be tagged as a treetop.


```r
ttops <- TreeTopFinder(CHM = kootenayCHM, winFun = lin, minHeight = 2)
```

We can now plot these treetops on top of the CHM.


```r
# Plot CHM
plot(kootenayCHM, xlab = "", ylab = "", xaxt='n', yaxt = 'n')

# Add dominant treetops to the plot
plot(ttops, col = "blue", pch = 20, cex = 0.5, add = TRUE)
```

![](treetopAnalysis_files/figure-html/unnamed-chunk-7-1.png)<!-- -->

The `ttops` object created by `TreeTopFinder` in this example contains the spatial coordinates of each detected treetop, as well as two default attributes: _height_ and _radius_. These correspond to the tree's height above ground and the radius of the moving window where the tree was located. Note that this _radius_ **is not necessarily equivalent to crown radius**.


```r
# Get the mean treetop height
mean(ttops$height)
```

```
## [1] 5.070345
```

## Spatial statistics

Managed forests are often divided into discrete spatial units. In British Columbia, for instance, these can range from cut blocks measuring a few hectares to [timber supply areas](https://www.for.gov.bc.ca/ftp/HTH/external/!publish/web/timber-tenures/tfl-regions-tsas-districts-map-350-dpi-april-10-2014.pdf) spanning several hundred square kilometers. The forest composition within these spatial units can be characterized through summarized statistics of tree attributes. For instance, a timber license holder may want a rough estimate of the number of dominant trees within a woodlot, while the standard deviation of tree height is of interest to anyone mapping heterogeneous old growth forest.

The `TreeTopSummary` function can be used to count trees within a set of spatial units, as well as compute statistics of the trees' attributes. These spatial units can be in the form of spatial polygons, or can be generated in the form of a raster grid.

When no specific area is defined, `TreeTopSummary` will simply return the count of all inputted trees.

```r
TreeTopSummary(ttops)
```

```
##           Value
## TreeCount  1211
```

By defining `variables`, `TreeTopSummary` can also generate summarized statistics.


```r
TreeTopSummary(ttops, variables = "height")
```

```
##                    Value
## TreeCount    1211.000000
## heightMean      5.070345
## heightMedian    3.910026
## heightSD        2.957289
## heightMin       2.002042
## heightMax      13.491207
```

### Stastics by polygon

The Forest Tools package includes the boundaries of three cutting blocks that can be overlayed on `kootenayCHM`. Tree counts and height statistics can be summarized within these boundaries using the `areas` argument.


```r
data("kootenayBlocks")

# Compute tree count and height statistics for cut blocks
blockStats <- TreeTopSummary(ttops, areas = kootenayBlocks, variables = "height")

# Plot CHM
plot(kootenayCHM, xlab = "", ylab = "", xaxt='n', yaxt = 'n')

# Add block outlines to the plot
plot(kootenayBlocks, add = TRUE, border =  "darkmagenta", lwd = 2)

# Add tree counts to the plot
library(rgeos)
text(gCentroid(kootenayBlocks, byid = TRUE), blockStats[["TreeCount"]], col = "darkmagenta", font = 2)
```

![](treetopAnalysis_files/figure-html/unnamed-chunk-11-1.png)<!-- -->

```r
# View height statistics
blockStats@data
```

```
##   BlockID Shape_Leng Shape_Area TreeCount heightMean heightMedian
## 0     101   304.3290   3706.389       313   7.329356     7.523089
## 1    3308   508.6240   6712.607       627   2.988681     2.668048
## 2     113   239.5202   2767.266       265   7.333409     7.997055
##    heightSD heightMin heightMax
## 0 2.7266677  2.003668 13.491207
## 1 0.9605248  2.002042  7.125149
## 2 2.7344077  2.033117 12.583441
```

### Stastics by grid

Instead of defining polygonal areas, the `TreeTopStatistics` function can also generate counts and stastics in raster format. In this case, the `grid` argument should be used instead of `areas`.
If you have an existing raster with the extent, cell size and alignment that you would like to use, it can be input as the `grid` argument. Otherwise, simply entering a numeric value will generate a raster with that cell size.


```r
# Compute tree count within a 10 m x 10 m cell grid
gridCount <- TreeTopSummary(treetops = ttops, grid = 10)

# Plot grid
plot(gridCount, col = heat.colors(255), xlab = "", ylab = "", xaxt='n', yaxt = 'n')
```

![](treetopAnalysis_files/figure-html/unnamed-chunk-12-1.png)<!-- -->

If, in addition to tree count, tree attribute statistics are computed, the object returned by `TreeTopSummary` will be a [RasterBrick](https://cran.r-project.org/package=raster/raster.pdf#page=36), i.e.: a multi-layered raster.


```r
# Compute tree height statistics within a 10 m x 10 m cell grid
gridStats <- TreeTopSummary(treetops = ttops, grid = 10, variables = "height")

# View layer names
names(gridStats)
```

```
## [1] "TreeCount"    "heightMean"   "heightMedian" "heightSD"    
## [5] "heightMin"    "heightMax"
```

Use the `[[]]` subsetting operator to extract a single layer.


```r
# Plot mean tree height within 10 m x 10 m cell grid
plot(gridStats[["heightMean"]], col = heat.colors(255), xlab = "", ylab = "", xaxt='n', yaxt = 'n')
```

![](treetopAnalysis_files/figure-html/unnamed-chunk-14-1.png)<!-- -->


## Outlining tree crowns

Canopy height models often represent continuous, dense forests, where tree crowns abut against eachother. Outlining discrete crown shapes from this type of forest is often refered to as _canopy segmentation_, where each crown outline is represented by a _segment_. Once a set of treetops have been detected from a canopy height model, the `SegmentCrowns` function can be used for this purpose.

The `SegmentCrowns` function implements the `watershed` algorithm from the [imager](https://cran.r-project.org/package=imager/imager.pdf) library. Watershed algorithms are frequently used in topograhical analysis to outline drainage basins. Given the morphological similarity between an inverted canopy and a terrain model, this same process can be used to outline tree crowns. However, a potential problem is the issue of _oversegmentation_, whereby branches, bumps and other spurious treetops are given their own segments. This source of error can be mitigated by using a variant of the algorithm known as _marker-controlled segmentation_ (Beucher & Meyer, 1993), whereby the watershed algorithm is constrained by a set of markers--in this case, treetops.

The `SegmentCrowns` function also takes a `minHeight` argument, although this value should be lower than that which was assigned to `TreeTopFinder`. For the latter, `minHeight` defines the lowest expected treetop, whereas for the former it should correspond to the height above ground of the fringes of the lowest trees. 


```r
# Create crown map
crowns <- SegmentCrowns(treetops = ttops, CHM = kootenayCHM, minHeight = 1.5)

# Plot crowns
plot(crowns, col = sample(rainbow(50), length(crowns), replace = TRUE), legend = FALSE, xlab = "", ylab = "", xaxt='n', yaxt = 'n')
```

![](treetopAnalysis_files/figure-html/unnamed-chunk-15-1.png)<!-- -->

`SegmentCrowns` returns a raster, where each crown is given a unique cell value. Depending on the intended purpose of the crown map, it may be preferable to store these outlines as polygons. The `rasterToPolygons` function from the `raster` package can be used for this purpose. Note that this conversion can be very slow for large datasets.


```r
# Convert raster crown map to polygons
crownsPoly <- rasterToPolygons(crowns, dissolve = TRUE)

# Plot CHM
plot(kootenayCHM, xlab = "", ylab = "", xaxt='n', yaxt = 'n')

# Add crown outlines to the plot
plot(crownsPoly, border = "blue", lwd = 0.5, add = TRUE)
```

![](treetopAnalysis_files/figure-html/unnamed-chunk-16-1.png)<!-- -->

Once converted to polygons, the two-dimensional area of each outline can be computed using the `gArea` function from the [rgeos](https://cran.r-project.org/package=rgeos/rgeos.pdf) package (also is installed during the installation of Forest Tools).


```r
library(rgeos)

# Compute crown area
crownsPoly[["area"]] <- gArea(crownsPoly, byid = TRUE)
```

Assuming that each crown has a roughly circular shape, we can use the crown's area to compute it's average circular diameter.


```r
# Compute average crown diameter
crownsPoly[["diameter"]] <- sqrt(crownsPoly[["area"]]/ pi) * 2

# Mean crown diameter
mean(crownsPoly$diameter)
```

```
## [1] 2.710377
```

## Handling large datasets

Canopy height models are frequently stored as very large raster datasets (> 1 GB). This can present a problem, since loading such a large dataset into memory can cause performance issues.

To handle large datasets, both the `TreeTopFinder` and `SegmentCrowns` functions have a built-in functionality whereby an inputted CHM can be automatically divided into tiles, which are then processed individually and then reassembled into a single output. This functionality is controlled with the `maxCells` argument: any input CHM with a higher number of cells will be divided into tiles for processing.

Since both the `TreeTopFinder` and `SegmentCrowns` processes can be subject to edge effects, these tiles are automatically buffered. While the buffers created by `TreeTopFinder` are set according to maximum window size, the buffers for `SegmentCrowns` are defined by the user using the `tileBuffer` argument, which should be equal to half the diameter of the widest expected tree crown.

Though the automatic tiling feature can improve performance and limit the amount of memory used during processing, both functions will still return a single output file, which in itself can be very large and still overload memory. Therefore, while automatic tiling is provided for user conveninence, it may still be a better practice to pre-tile large datasets and store outputs in tiled form.

## Reading and writing geospatial data in R {#readsave}

### The _raster_ and _sp_ libraries
The Forest Tools package is built on the [raster](https://cran.r-project.org/package=raster) and [sp](https://cran.r-project.org/package=sp) libraries, which are automatically installed when `ForestTools` is downloaded. These libraries define a variety of classes and functions for working with raster and vector datasets in R.

It is recommended that any user performing geospatial analyses in R be familiar with both of these libraries. Relatively easy and straightforward guides for  [raster](https://cran.r-project.org/package=raster/vignettes/Raster.pdf) and [sp](https://cran.r-project.org/package=sp/vignettes/intro_sp.pdf) have been written by their respective authors.

### Geospatial classes used by Forest Tools


Data product          Data type             Object class                                                                     
--------------------  --------------------  ---------------------------------------------------------------------------------
Canopy height model   Single-layer raster   [RasterLayer](https://cran.r-project.org/package=raster/raster.pdf#page=159)     
Treetops              Points                [SpatialPointsDataFrame](https://cran.r-project.org/package=sp/sp.pdf#page=84)   
Crown outlines        Polygons              [SpatialPolygonsDataFrame](https://cran.r-project.org/package=sp/sp.pdf#page=89) 
Gridded statistics    Multi-layer raster    [RasterBrick](https://cran.r-project.org/package=raster/raster.pdf#page=159)     

### Raster files

To load a raster file, such as a CHM, use the `raster` function from the `raster` library (both the function and the library have the same name). Simply provide a path to a valid raster file. Don't forget to use either double backslashes `\\` or forward slashes `/` in the file path.


```r
library(raster)

# Load a canopy height model
inCHM <- raster("C:\\myFiles\\inputs\\testCHM.tif")
```

Once you have performed your analysis, use the `writeRaster` function to save any raster files you may have produced. Setting an appropriate [dataType](https://cran.r-project.org/package=raster/raster.pdf#page=65) is optional, but can save disk space.


```r
# Write a crown map raster file
writeRaster(crowns, "C:\\myFiles\\outputs\\crowns.tif", dataType = "INT2U")
```

### Polygon and point files

There are many options for saving point and polygon files to disk. The [rgdal](https://cran.r-project.org/package=rgdal/rgdal.pdf) library provides functions for reading and writing the most common vector formats. The following examples use ESRI Shapefiles.

Use the `readOGR` function to load a polygonal ESRI Shapefile. Instead of providing an entire file path, `readOGR` takes two separate arguments: the file's directory, followed by the file name _without_ an extension. The following would import a file named _"C:\\myFiles\\blockBoundaries\\block375.shp"_.


```r
library(rgdal)

# Load the 'block375.shp' file
blk375boundary <- readOGR("C:\\myFiles\\blockBoundaries", "block375")
```

Follow this same convention for saving a vector file to disk using `writeOGR`. A `driver` must also be specified.


```r
# Save a set of dominant treetops
writeOGR(ttops, "C:\\myFiles\\outputs", "treetops", driver = "ESRI Shapefile")
```

## References

Popescu, S. C., & Wynne, R. H. (2004). [Seeing the trees in the forest](http://www.ingentaconnect.com/content/asprs/pers/2004/00000070/00000005/art00003). _Photogrammetric Engineering & Remote Sensing, 70_(5), 589-604.

Beucher, S., and Meyer, F. (1993). [The morphological approach to segmentation: the watershed transformation](https://www.researchgate.net/profile/Serge_Beucher/publication/233950923_Segmentation_The_Watershed_Transformation_Mathematical_Morphology_in_Image_Processing/links/55f7c6ce08aeba1d9efe4072.pdf). _Mathematical morphology in image processing_, 433-481.

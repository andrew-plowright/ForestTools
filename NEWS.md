## ForestTools 0.3.0

- Removed `sp_summarise`. If you thought this tool was useful and would like me to restore it, please let me know.


## ForestTools 0.2.6

Behaviour change for `gclm`: images are now discretized BEFORE segmentation. Note that this will impact the results returned by the function.


## ForestTools 0.2.5

Added `glcm_img` to allow GLCM statistics to be computed for an entire unsegmented image.

## ForestTools 0.2.4

The `radiomics` package is no longer maintained, so with permission from the author, Joel Carlson, I've integrated the code for computing GLCM statistics into this library

## ForestTools 0.2.1

Added:

* `kootenayOrtho`, an orthographic image of the area covered by `kootenayCHM`, `kootenayTrees` and `kootenayCrowns`

New function:

* `glcm`, for computing textural metrics of a segmented canopy. Thanks to Jean-Romain Roussel for providing code for this function.

## ForestTools 0.2.0

**BACKWARD INCOMPATIBILITY WARNING**

Although this can cause backward compatibility issues, I felt it was necessary to rename the following functions:

* `TreetopFinder` -> `vwf` (stands for _Variable Window Filter_)

* `SegmentCrowns` -> `mcws` (stands for _Marker-Controlled Watershed Segmentation_)

* `SpatialStatistics` -> `sp_summarise`

Reasons for the changes are:

1. To follow the convention of avoiding capitalized function names.
2. To bring more specificity to the underlying algorithms involved.
3. To credit the developers of said algorithms by using the names assigned to them.
4. To acknowledge the fact that alternative algorithms are available for both finding trees and segmenting crowns.

In addition, I've made the following changes to `vwf` (formerly `TreetopFinder`):

* Extended the default value of the `maxWinDiameter` argument to 99. Note that this value sets the maximum width in _cells_ of the widest allowable window diameter. As explained in the documentation, this argument is to prevent the function from gobbling up too much memory, and can be disabled by setting to NULL.
* In addition to controlling the _maximum_ window diameter, the user can now tweak the behavior of the _minimum_ diameter as well. Essentially, the smallest window will always be a 3x3 cell window, regardless of the computed window radius. The neighborhood of this smallest window can be set to either [a rook or a queen case contiguity](https://i.stack.imgur.com/CWIHi.jpg) using the `minWinNeib` argument.
* I've removed the function's compatibility with the `TileManager` package. Although I had put considerable effort into adding this feature initially, I've realized that A) no one was using it, B) it is preferable for the user to manage tiles him or herself instead of having them managed "under the hood" by the `vwf` function. Let me know if you thought this feature was useful and perhaps I can write a vignette suggesting preferable ways to manage a tiled CHM.

## ForestTools 0.1.5

* Fixed a persistent bug in 'TreeTopFinder' whereby CHMs with imprecise cell sizes (i.e.: cell dimensions that aren't accurate after a certain number of decimals), would cause issues with the shape of the focal windows. Internally, CHM cell dimensions are now rounded to the fifth decimal.

## ForestTools 0.1.4

* Add a new option for generating polygonal tree crowns with 'SegmentCrowns' using GDAL utilities from OSGeo4W. See documentation for 'SegmentCrowns' as well as new vignette: "Options for creating polygonal crown maps".

## ForestTools 0.1.2

* Added the 'Quesnel' dataset. Added a new vignette: "Calculating inventory attributes using Forest Tools".

## ForestTools 0.1.1

* Modified 'SegmentCrowns' function so that it can produce tree crowns in polygon format. The function will also calculate crown area, and filter out crowns that are not associated with a treetop point location.

* Changed name of 'TreeTopSummary' function to 'SpatialStatistics'. This reflects its new functionality, which allows crown maps to be inputted as well as treetop locations. 

## ForestTools 0.1.0

* Initial release of ForestTools


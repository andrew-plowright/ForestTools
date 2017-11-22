## ----global_options, include=FALSE, dpi =  300---------------------------
knitr::opts_knit$set(global.par = TRUE)

## ---- eval = FALSE-------------------------------------------------------
#  update.packages()
#  
#  packageVersion("APfun")

## ---- eval = FALSE-------------------------------------------------------
#  library(ForestTools)
#  
#  data("kootenayCHM")
#  data("kootenayTrees")
#  
#  kootenayCrowns <- SegmentCrowns(kootenayTrees, kootenayCHM, minHeight = 1.5, format = "polygons", OSGeoPath = "C:\\OSGeo4W64")


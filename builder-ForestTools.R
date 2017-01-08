
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

### SET PACKAGE SETTINGS

  library(rgeos)
  library(raster)
  library(rgdal)
  library(imager)
  devtools::use_package("imager")
  devtools::use_package("sp")
  devtools::use_package("raster")
  devtools::use_package("rgeos")
  devtools::use_package("rgdal")
  devtools::use_package("TileManager")
  devtools::use_package("maptools")

  devtools::use_testthat()
  devtools::use_data_raw()

### PERFORM ACTIONS

  devtools::test()
  devtools::document()
  devtools::load_all()

### TO DO LIST


  # COMMIT 1 - Create Vignette

  # COMMIT 2 - Upload to CRAN

    # Remove 'PLACEHOLDER' from DESCRIPTION and package documentation

  # BACKBURNER

    # Look up DevTools global options to see if global options can be changed
    # permanently



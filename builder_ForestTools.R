
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

### SET PACKAGE SETTINGS

  devtools::use_package("imager")
  devtools::use_package("sp")
  devtools::use_package("raster")
  devtools::use_package("rgeos")
  devtools::use_package("rgdal")
  devtools::use_package("TileManager")
  devtools::use_package("maptools")
  devtools::use_package("APfun")
  devtools::use_package("methods")

  devtools::use_testthat()
  devtools::use_travis()
  devtools::use_readme_rmd()
  devtools::use_news_md()
  devtools::use_cran_comments()

  devtools::use_build_ignore("builder_ForestTools.R")
  devtools::use_build_ignore("testdata-raw")
  devtools::use_build_ignore("oldfunctions")

  devtools::use_vignette("treetopAnalysis")

### PERFORM ACTIONS

  devtools::test()
  devtools::document()
  devtools::load_all()
  devtools::check()
  devtools::build_win()
  devtools::release()

### TO DO LIST

  # COMMIT 1 - Create Vignette

  # COMMIT 2 - Upload to CRAN

    # Remove 'PLACEHOLDER' from DESCRIPTION and package documentation

  # BACKBURNER

    # Look up DevTools global options to see if global options can be changed
    # permanently



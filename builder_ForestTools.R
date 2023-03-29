#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

### SET PACKAGE SETTINGS

  usethis::use_package("imager")
  usethis::use_package("sp")
  usethis::use_package("raster")
  usethis::use_package("rgeos")
  usethis::use_package("rgdal")
  usethis::use_package("maptools")
  usethis::use_package("APfun")
  usethis::use_package("methods")

  usethis::use_testthat()
  usethis::use_readme_rmd()
  usethis::use_news_md()
  usethis::use_cran_comments()

  usethis::use_build_ignore("builder_ForestTools.R")

  usethis::use_git_ignore("scratch.R")

  usethis::use_vignette("treetopAnalysis")
  usethis::use_vignette("polygonalCrownMaps")
  usethis::use_vignette("inventoryAttributes")

### SET QPDF PATH

  Sys.setenv(R_QPDF = "C:\\Program Files\\qpdf-5.1.2\\bin\\qpdf.exe")

### PERFORM ACTIONS

  # Document and vignettes
  devtools::document()
  devtools::build_vignettes()

  # Run tests locally
  devtools::test()

  # R CMD check
  devtools::check()

  # Devtools' extra checks
  devtools::spell_check()
  devtools::check_rhub()
  devtools::check_win_devel()

  # Reminders
  # - Change date in DESCRIPTION
  # - Change version in DESCRIPTION
  # - Update NEWS file

  # RELEASE!
  devtools::release()

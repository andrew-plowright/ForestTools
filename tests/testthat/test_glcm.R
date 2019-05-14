library(ForestTools)

context("Tests for 'glcm'")


  segs <- mcws(kootenayTrees, kootenayCHM, minHeight = 0.2, format = "raster")

  test_that("glcm: expected results using standard parameters", {

    tex <- glcm(segs, kootenayOrtho[[1]])

    # All segments are included
    expect_true(all(na.omit(unique(segs[])) %in% tex$treeID))

    # No missing values
    expect_false(any(is.na(tex$glcm_mean)))

  })

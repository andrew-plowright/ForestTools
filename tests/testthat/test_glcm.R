library(ForestTools)

context("Tests for 'glcm'")


  segs <- mcws(kootenayTrees, kootenayCHM, minHeight = 0.2, format = "raster")

  test_that("glcm: standar processing ", {

    tex1 <- glcm(segs, kootenayOrtho[[1]])
    #tex2 <- glcm(segs, kootenayOrtho[[1]], clusters = 3)

    # Parallel and serial processing were identical
    #expect_true(identical(tex1, tex2))

    # All segments are included
    expect_true(all(na.omit(unique(segs[])) %in% tex1$treeID))

    # No missing values
    expect_false(any(is.na(tex1$glcm_mean)))

    expect_equal(tex1[1, "glcm_mean"], 113.3889, tolerance = 0.001)
    expect_equal(tex1[1, "glcm_IDN"], 0.8422897, tolerance = 0.001)
    expect_equal(tex1[1, "glcm_sumVariance"], 0, tolerance = 0.001)

  })

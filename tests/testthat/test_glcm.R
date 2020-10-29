library(ForestTools)

context("Tests for 'glcm'")

  testExtent <- raster::extent(439740.0,  439781.7, 5526491.8, 5526523.5)
  testTrees  <- raster::crop(kootenayTrees,      testExtent)
  testCHM    <- raster::crop(kootenayCHM,        testExtent)
  testImg    <- raster::crop(kootenayOrtho[[1]], testExtent)

  # Create segments
  segs <- mcws(testTrees, testCHM, minHeight = 0.2, format = "raster")

  # Compute texture with standard segments
  tex1 <- glcm(segs, testImg)
  #tex2 <- glcm(segs, kootenayOrtho[[1]], clusters = 3)

  test_that("glcm: standard processing ", {

    # Parallel and serial processing were identical
    #expect_true(identical(tex1, tex2))

    # All segments are included
    expect_true(all(na.omit(unique(segs[])) %in% tex1$treeID))

    # No missing values
    expect_false(any(is.na(tex1$glcm_mean)))

    expect_equal(tex1[1, "glcm_mean"],            98,     tolerance = 0.001)
    expect_equal(tex1[1, "glcm_IDN"],             0.9047, tolerance = 0.001)
    expect_equal(tex1[1, "glcm_inverseVariance"], 0.6666, tolerance = 0.001)

  })

  # Create blank segments
  segs_empty <- raster::setValues(segs, NA)

  test_that("glcm: gives empty data.frame if no valid segments are provided", {

    # Compute text with blank segments
    tex_empty <- glcm(segs_empty, testImg)

    expect_equal(nrow(tex_empty), 0)
    expect_equal(names(tex1), names(tex_empty))

  })

  # Create an image with some blank values
  img_withNA <- testImg
  img_withNA[,40:70] <- NA


  test_that("glcm: gives empty data.frame if no valid segments are provided", {

    expect_warning(tex_withNA <- glcm(segs, img_withNA), "Matrix composed entirely of NA's", all = TRUE)

  })



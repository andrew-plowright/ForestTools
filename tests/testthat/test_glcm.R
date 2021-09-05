context("Tests for 'glcm'")

# Read in test data
testExtent <- raster::extent(439740.0,  439781.7, 5526491.8, 5526523.5)
testTrees  <- raster::crop(kootenayTrees,      testExtent)
testCHM    <- raster::crop(kootenayCHM,        testExtent)
testImg    <- raster::crop(kootenayOrtho[[1]], testExtent)

# Create segments
segs <- mcws(testTrees, testCHM, minHeight = 0.2, format = "raster")

# Create blank segments
segsEmpty <- raster::setValues(segs, NA)

# Create an image with some blank values
testImgNA <- testImg
testImgNA[,40:70] <- NA

# Create image with negative values
testImgNeg <- testImg
testImgNeg[1] <- -1

test_that("glcm: standard processing ", {

  # Compute texture with standard segments
  tex1 <- glcm(segs, testImg)

  # All segments are included
  expect_true(all(na.omit(unique(segs[])) %in% tex1$treeID))

  # No missing values
  expect_false(any(is.na(tex1$glcm_mean)))

  expect_equal(tex1[1, "glcm_mean"],            98,     tolerance = 0.001)
  expect_equal(tex1[1, "glcm_IDN"],             0.9047, tolerance = 0.001)
  expect_equal(tex1[1, "glcm_inverseVariance"], 0.6666, tolerance = 0.001)

})

test_that("glcm: gives empty data.frame if no valid segments are provided", {

  # Compute text with blank segments
  tex_empty <- glcm(segsEmpty, testImg)

  expect_equal(nrow(tex_empty), 0)

})

test_that("glcm: gives empty data.frame if no valid segments are provided", {

  expect_warning(
    glcm(segs, testImgNA),
    "Could not calculate GLCM stats", all = TRUE)

})

test_that("glcm_img: successful", {

  tex <- glcm_img(testCHM)

  expect_equal(tex[1, "glcm_mean"],     7.067751, tolerance = 0.001)
  expect_equal(tex[1, "glcm_entropy"], 6.136393,  tolerance = 0.001)
  expect_equal(tex[1, "glcm_maxProb"], 0.1277584, tolerance = 0.001)


})

test_that("glcm_img: failures", {

  expect_error(glcm_img(testImgNA), "Input image cannot have NA values")

  expect_error(glcm_img(testImgNeg, "Input image cannot have negative values"))

})


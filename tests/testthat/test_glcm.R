context("Tests for 'glcm'")

# Read in test data
test_ext <- terra::ext(439740.0,  439781.7, 5526491.8, 5526523.5)
test_chm <- terra::crop(terra::rast(kootenayCHM),        test_ext)
test_img <- terra::crop(terra::rast(kootenayOrtho)[[1]], test_ext)

sf::st_agr(kootenayTrees) <- "constant"
test_trees <- sf::st_crop(kootenayTrees, sf::st_bbox(test_ext))

# Create segments
segs <- mcws(test_trees, test_chm, minHeight = 0.2, format = "raster")

# Create blank segments
segs_empty <- terra::setValues(segs, NA)

# Create an image with some blank values
test_img_na <- test_img
test_img_na[,40:70] <- NA

# Create image with negative values
test_img_neg <- test_img
test_img_neg[1] <- -1


test_that("glcm: standard processing ", {

  # Compute texture with standard segments
  tex1 <- glcm(segs, test_img)

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
  tex_empty <- glcm(segs_empty, test_img)

  expect_equal(nrow(tex_empty), 0)
})

test_that("glcm: gives empty data.frame if no valid segments are provided", {

  expect_warning(
    glcm(segs, test_img_na),
    "Could not calculate GLCM stats", all = TRUE)
})

test_that("glcm_img: successful", {

  tex <- glcm_img(test_chm)

  expect_equal(tex[1, "glcm_mean"],     7.067751, tolerance = 0.001)
  expect_equal(tex[1, "glcm_entropy"], 6.136393,  tolerance = 0.001)
  expect_equal(tex[1, "glcm_maxProb"], 0.1277584, tolerance = 0.001)
})

test_that("glcm_img: failures", {

  expect_error(glcm_img(test_img_na), "Input image cannot have NA values")
  expect_error(glcm_img(test_img_neg, "Input image cannot have negative values"))
})


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
test_img_empty <- terra::setValues(test_img, NA)


test_that("glcm_img: successful", {

  tex <- glcm(test_chm)

  expect_equal(tex[1, "glcm_mean"],     7.067751, tolerance = 0.001)
  expect_equal(tex[1, "glcm_entropy"], 6.136393,  tolerance = 0.001)
  expect_equal(tex[1, "glcm_maxProb"], 0.1277584, tolerance = 0.001)
})

test_that("glcm: with segments", {

  # Compute texture with standard segments
  tex1 <- glcm(test_img, segs)

  # All segments are included
  expect_true(all(na.omit(unique(terra::values(segs, mat=FALSE))) %in% row.names(tex1)))

  # No missing values
  expect_false(any(is.na(tex1$glcm_mean)))

  expect_equal(tex1[1, "glcm_mean"],            13.100, tolerance = 0.001)
  expect_equal(tex1[1, "glcm_IDN"],              0.750, tolerance = 0.001)
  expect_equal(tex1[1, "glcm_inverseVariance"],  1.000, tolerance = 0.001)
})

test_that("glcm: errors with empty inputs", {

  # Compute text with blank segments
  expect_error(glcm(test_img, segs_empty), "'segs' must contain usable values")
  expect_error(glcm(test_img_empty, segs), "'image' must contain usable values")

})






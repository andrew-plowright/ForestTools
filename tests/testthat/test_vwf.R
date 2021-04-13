library(ForestTools)

context("Tests for 'vwf'")

### LOAD TEST DATA ----

  load("testData/testTrees.Rda")
  load("testData/testCHM.Rda")
  load("testData/emptyCHM.Rda")
  load("testData/lowResCHM.Rda")
  load("testData/latlongCHM.Rda")

### PERFORM TESTS ----

  test_that("vwf: expected results using standard parameters", {

    trees.std <- vwf(testCHM, function(x){x * 0.05 + 0.8}, minHeight = 1.5)

    expect_equal(length(trees.std), 1115)
    expect_equal(mean(trees.std[["height"]]), 5.857549, tolerance = 0.0000001)
    expect_equal( min(trees.std[["height"]]), 1.503213, tolerance = 0.0000001)
    expect_equal( max(trees.std[["height"]]), 26.89251, tolerance = 0.0000001)
  })

  test_that("vwf: returns an error if the input function produces windows that are too large", {

    expect_error(vwf(testCHM, function(x){x * 0.2 + 20}, minHeight = 1, maxWinDiameter = 20),
                 "Input function for \'winFun\' yields a window")
  })

  test_that("vwf: returns an error if 'minHeight' is too high",{

    err <- "\'minHeight\' is set to a value higher than the highest cell value in 'CHM'"

    expect_error(vwf(testCHM, function(x){x * 0.05 + 0.8}, minHeight = 40), err)
    expect_error(vwf(testCHM, function(x){x * 0.05 + 0.8}, minHeight = 40, maxWinDiameter = 10), err)
  })

  test_that("vwf: returns an error if 'CHM' is empty",{

    err <-  "Input 'CHM' does not contain any usable values."

    expect_error(vwf(emptyCHM, function(x){x * 0.05 + 0.8}), err)
  })

  test_that("vwf: error if window size is too low for a given CHM",{

    err  <- "The map units of the 'CHM' are too small"
    warn <- "'CHM' map units are in degrees"

    expect_warning(expect_error(vwf(latlongCHM, function(x){x * 0.03 + 0.2}), err), warn)
  })




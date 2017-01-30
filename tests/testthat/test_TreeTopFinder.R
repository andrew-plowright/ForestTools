library(ForestTools)

context("Tests for TreeTopFinder")

### LOAD TEST DATA

load("testTrees.Rda")
load("testCHMtiles.Rda")
load("testCHM.Rda")
load("emptyCHM.Rda")

### PERFORM TESTS

  test_that("TreeTopFinder: expected results using standard parameters", {

    trees.std <- TreeTopFinder(testCHM, function(x){x * 0.05 + 0.8}, minHeight = 1.5)

    expect_equal(length(trees.std), 1115)
    expect_equal(mean(trees.std[["height"]]), 5.857549, tolerance = 0.0000001)
    expect_equal(min(trees.std[["height"]]), 1.503213, tolerance = 0.0000001)
    expect_equal(max(trees.std[["height"]]), 26.89251, tolerance = 0.0000001)
  })

  test_that("TreeTopFinder: expected results using forced tiling", {

    trees.tiled <- TreeTopFinder(testCHM, function(x){x * 0.05 + 0.8}, minHeight = 1.5, maxCells = 10000)

    expect_equal(length(trees.tiled), 1115)
    expect_equal(mean(trees.tiled[["height"]]), 5.857549, tolerance = 0.0000001)
    expect_equal(min(trees.tiled[["height"]]), 1.503213, tolerance = 0.0000001)
    expect_equal(max(trees.tiled[["height"]]), 26.89251, tolerance = 0.0000001)
  })


  test_that("TreeTopFinder: expected results using pre-tiled CHM", {

    trees.tiled <- TreeTopFinder(testCHM.tiles, function(x){x * 0.05 + 0.8}, minHeight = 1.5, maxCells = 10000)

    expect_equal(length(trees.tiled), 1115)
    expect_equal(mean(trees.tiled[["height"]]), 5.857549, tolerance = 0.0000001)
    expect_equal(min(trees.tiled[["height"]]), 1.503213, tolerance = 0.0000001)
    expect_equal(max(trees.tiled[["height"]]), 26.89251, tolerance = 0.0000001)
  })

  test_that("TreeTopFinder: returns an error if the input function produces windows that are too large", {
    expect_error(TreeTopFinder(testCHM, function(x){x * 0.2 + 20}, minHeight = 1, maxWinDiameter = 20),
                 "Input function for \'winFun\' yields a window size")
    expect_error(TreeTopFinder(testCHM, function(x){x * 0.2 + 20}, minHeight = 1, maxWinDiameter = 20, maxCells = 5000),
                 "Input function for \'winFun\' yields a window size")
  })

  test_that("TreeTopFinder: returns an error if 'minHeight' is too high",{

    err <- "\'minHeight\' is set higher than the highest cell value in \'CHM\'"

    expect_error(TreeTopFinder(testCHM, function(x){x * 0.05 + 0.8}, minHeight = 40), err)
    expect_error(TreeTopFinder(testCHM, function(x){x * 0.05 + 0.8}, minHeight = 40, maxWinDiameter = 10), err)
    expect_error(TreeTopFinder(testCHM, function(x){x * 0.05 + 0.8}, minHeight = 40, maxCells = 5000), err)
  })

  test_that("TreeTopFinder: returns an error if 'CHM' is empty",{

    err <-  "Input CHM does not contain any usable values."

    expect_error(TreeTopFinder(emptyCHM, function(x){x * 0.05 + 0.8}), err)
  })


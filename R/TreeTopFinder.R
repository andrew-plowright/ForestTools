#' Treetop Finder
#'
#' Implements the variable window filter algorithm (Popescu & Wynne, 2004) for detecting treetops from a canopy height model.
#' @param CHM Canopy height model. Either in \link[raster]{raster} format, or a path directing to a raster file. A character vector of multiple paths directing to a
#' tiled raster dataset can also be used.
#' @param winFun function. Should take the value of a given \code{CHM} pixel as its only argument, and return the radius of the corresponding search window.
#' @param minHeight numeric. The minimum height value for a \code{CHM} pixel to be considered as a potential treetop. All \code{CHM} pixels beneath
#' this value will be masked out.
#' @param maxCells numeric. If the number of raster cells for the \code{CHM} exceeds this value, the \link[TileManager]{TileScheme} function
#' will be applied to break apart the input into tiles to speed up processing.
#' @param maxWinDiameter numeric. This parameter prevents \code{TreeTopFinder} from being run with a function that would
#' produce very large windows, which will affect performance and is likely a sign of an inappropriate window function. Can be disabled
#' by setting to \code{NULL}.
#' @param verbose logical. Print progress to console if set to \code{TRUE}.
#' @references Popescu, S. C., & Wynne, R. H. (2004). Seeing the trees in the forest. Photogrammetric Engineering & Remote Sensing, 70(5), 589-604.
#' @return \link[sp]{SpatialPointsDataFrame}. The point locations of detected treetops. The object contains two fields in its
#' data table: \code{height} is the height of the tree, as extracted from the \code{CHM}, and \code{radius} is the radius
#' of the search window when the treetop was detected. Note that \code{radius} does not necessarily correspond to the radius
#' of the tree's crown.
#' @examples
#' # Set function for determining variable window radius
#' winFunction <- function(x){x * 0.06 + 0.5}
#'
#' # Set minimum tree height (treetops below this height will not be detected)
#' minHgt <- 2
#'
#' # Detect treetops in demo canopy height model
#' ttops <- TreeTopFinder(CHMdemo, winFunction, minHgt)
#' @seealso \code{\link{SegmentCrowns}} \code{\link{TreeTopSummary}}

#' @export

TreeTopFinder <- function(CHM, winFun, minHeight = NULL, maxCells = 2000000, maxWinDiameter = 30, verbose = FALSE){

  ### GATE-KEEPER

    # Convert single Raster object or paths to raster files into a list of Raster objects
    CHM <- TileManager:::TileInput(CHM, "CHM")

    if(!is.null(minHeight)){
      if(minHeight <= 0){stop("Minimum canopy height must be set to a positive value.")}
    }

  ### PRE-PROCESS: CREATE FUNCTION TO RETURN EMPTY SPDF

    emptyOutput <- function(inCRS){
      sp::SpatialPointsDataFrame(crds <- matrix(0, nrow = 1, ncol = 2),
                               data = data.frame(height = 0, radius = 0),
                               proj4string = inCRS)[0,]
    }

  ### PRE-PROCESS: COMPUTE RANGE OF SEARCH WINDOWS

    if(verbose) cat("Reading input raster", "\n")

    # Get maximum and minimum values
    CHM.max <- max(sapply(CHM, function(tile) suppressWarnings(max(raster::getValues(tile), na.rm = TRUE))))
    CHM.min <- min(sapply(CHM, function(tile) suppressWarnings(min(raster::getValues(tile), na.rm = TRUE))))
    if(is.infinite(CHM.max) | is.infinite(CHM.min)){stop("Input CHM does not contain any usable values. Check input data or lower minimum canopy height.")}
    if(!is.null(minHeight)){
      if(minHeight > CHM.min){CHM.min <- minHeight}
      if(CHM.max <= CHM.min){stop("\'minHeight\' is set higher than the highest cell value in \'CHM\'")}
    }

    # Generate a list of radii
    radii <- seq(floor(winFun(CHM.min)), ceiling(winFun(CHM.max)), by = raster::res(CHM[[1]])[1])
    radii <- radii[radii != 0]

    # Calculate the dimensions of the largest matrix to be created from the generated list of radii
    maxDimension <- (max(radii) / raster::res(CHM[[1]])[1]) * 2 + 1

    # Check if input formula will yield a window size bigger than the maximum set by 'maxWinDiameter'
    if(!is.null(maxWinDiameter)){
      if(maxDimension > maxWinDiameter){
        stop("Input function for \'winFun\' yields a window size of ",  maxDimension,
             ", which is wider than \'maxWinDiameter\'.",
             "\nChange input function or set \'maxWinDiameter\' to a higher value (or to NULL).")
        }
    }

  ### PRE-PROCESS: MULTI-TILES CHECK

    # Detect/generate tiling scheme
    tiles <- TileManager:::TileApply(CHM, maxCells = maxCells, tileBuffer = ceiling((maxDimension - 1) / 2), verbose = verbose)

    # If input raster exceeds maximum number of cells, apply tiling scheme
    if(length(CHM) == 1 & raster::ncell(CHM[[1]]) > maxCells){

      CHM <- TileManager:::TempTiles(CHM[[1]], tiles)
      on.exit(TileManager:::removeTempTiles(), add = TRUE)
    }

  ### PRE-PROCESS: CREATE WINDOW OBJECTS AND VWF FUNCTION

    if(verbose) cat("Creating windows", "\n")

    # Cycle through input radii
    windows <- lapply(radii, function(radius){

      # Based on the unit size of the input CHM and a given radius, this function will create a matrix whose non-zero
      # values will form the shape of a circle.
      circle <- raster::focalWeight(CHM[[1]], radius, type = "circle")

      # The matrix is then be "padded" to the size of the biggest matrix created from the list of radii
      topBottomPad <- matrix(0, nrow = (maxDimension - ncol(circle)) / 2, ncol = ncol(circle))
      leftRightPad <- matrix(0, nrow = maxDimension, ncol = (maxDimension - ncol(circle)) / 2)
      paddedCircle <- cbind(leftRightPad, rbind(topBottomPad, circle, topBottomPad), leftRightPad)

      # The matrix values are then transformed into a vector of single dimension
      outVector <- as.vector(paddedCircle != 0)

      # The vector is the returned
      return(outVector)
    })

    # Rename the "windows" elements according to the input radii
    names(windows) <- radii

    # Create function to find local maxima based on vector of variable-sized windows.
    variableWindowLocalMaxima <- function(x, ...){

      # Locate central value in the moving window.
      centralValue <- x[length(x)/2+.5]

      # If central value is NA, then return NA.
      if(is.na(centralValue)){
        return(NA)
      }else{

        # Calculate the expected crown radius.
        radius <- winFun(centralValue)

        # Retrieve closest window size
        window <- windows[[which.min(abs(as.numeric(names(windows)) -  radius))]]

        # If the central value is the highest value within the variably-sized window (i.e.: local maxima), return 1. If not, return 0.
        if(max(x[window], na.rm = TRUE) == centralValue) {
          return(1)
        }else{
          return(0)}
      }
    }

  ### PROCESS: APPLY VWF FUNCTION

    if(verbose) cat("Processing tile...", "\n")

    ### PRE-PROCESS
    localMaxima.tiles <- lapply(1:length(CHM), function(tileNum){

      if(verbose) cat("  ", tileNum, "of", length(CHM), "\n")

      # Extract a given CHM tile and its non-overlapping buffered extent
      CHM.tile <- CHM[[tileNum]]
      nbuff.tile <- tiles$nbuffPolygons[tileNum,]

      # Apply minimum canopy height
      if(!is.null(minHeight)){CHM.tile[CHM.tile < minHeight] <- NA}

      # Apply local maxima-finding function to raster
      localMaxima.raster <- raster::focal(CHM.tile, w = matrix(1, sqrt(length(windows[[1]])), sqrt(length(windows[[1]]))), fun = variableWindowLocalMaxima, pad = TRUE, padValue = NA)

      # Extract the cell numbers of the local maxima
      localMaxima.cellNumbers <- which((localMaxima.raster[] == 1))

      # If no local maxima were found...
      if(length(localMaxima.cellNumbers) == 0){

        # Return a dummy SPDF with no coordinates
        localMaxima.spdf <- emptyOutput(raster::crs(CHM.tile))

      # If local maxima WERE found...
      }else{

        # Extract the height of each local maxima
        localMaxima.heights <- CHM.tile[localMaxima.cellNumbers]

        # Estimate radius for each point
        localMaxima.radius <- winFun(localMaxima.heights)

        # Create SpatialPoints object from local maxima centroids
        localMaxima.points <- raster::xyFromCell(localMaxima.raster, localMaxima.cellNumbers, spatial = TRUE)

        # Create SpatialPointsDataFrame object from point locations of local maxima, their heights and their radii.
        localMaxima.spdf <- sp::SpatialPointsDataFrame(localMaxima.points, data.frame(height = localMaxima.heights, radius = localMaxima.radius))

        # Subset local maxima that are within tile's non-overlapping buffered extent
        localMaxima.spdf <- localMaxima.spdf[rgeos::gContains(nbuff.tile, localMaxima.spdf, byid = TRUE)[,1],]
      }
      return(localMaxima.spdf)
    })

    # If tiles contain treetops, merge them into a single SPDF
    if(any(sapply(localMaxima.tiles, length) != 0)){

      pointsRbind <- function(...) {
        dots = list(...)
        names(dots) <- NULL # bugfix Clement Calenge 100417
        sp = do.call(sp::rbind.SpatialPoints, lapply(dots, function(x) methods::as(x, "SpatialPoints")))
        df = do.call(rbind, lapply(dots, function(x) x@data))
        sp::SpatialPointsDataFrame(sp, df, coords.nrs = dots[[1]]@coords.nrs)
      }

      localMaxima <- do.call(pointsRbind, localMaxima.tiles)

    # Otherwise, return the results of the first tile (an empty SPDF)
    }else{
      localMaxima <- localMaxima.tiles[[1]]
    }

    # Assign projection system to output SpatialPointsDataFrame
    raster::crs(localMaxima) <- raster::crs(CHM[[1]])

  ### OUTPUT
    return(localMaxima)
  }

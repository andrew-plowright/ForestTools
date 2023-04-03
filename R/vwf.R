#' Variable Window Filter
#'
#' Implements the variable window filter algorithm (Popescu & Wynne, 2004) for detecting treetops from a canopy height model.
#'
#' This function uses the resolution of the raster to figure out how many cells the window needs to cover.
#' This means that the raster value (representing height above ground) and the map unit (represented by the raster's resolution),
#' need to be in the _same unit_. This can cause issues if the raster is in lat/lon, whereby its resolution is in decimal degrees.
#'
#' @param CHM Canopy height model in SpatRaster format.
#' @param winFun function. The function that determines the size of the window at any given location on the
#' canopy. It should take the value of a given \code{CHM} pixel as its only argument, and return the desired *radius* of
#' the circular search window when centered on that pixel. Size of the window is in map units.
#' @param minHeight numeric. The minimum height value for a \code{CHM} pixel to be considered as a potential treetop. All \code{CHM} pixels beneath
#' this value will be masked out.
#' @param warnings logical. If set to FALSE, this function will not emit warnings related to inputs.
#' @param minWinNeib character. Define whether the smallest possible search window (3x3) should use a \code{queen} or
#' a \code{rook} neighborhood.
#' @param IDfield character. Name of field for unique tree identifier
#'
#' @references Popescu, S. C., & Wynne, R. H. (2004). Seeing the trees in the forest. \emph{Photogrammetric Engineering & Remote Sensing, 70}(5), 589-604.
#'
#' @return Simple feature collection of POINT type. The point locations of detected treetops. The object contains two fields in its
#' data table: \emph{height} is the height of the tree, as extracted from the \code{CHM}, and \emph{winRadius} is the radius
#' of the search window when the treetop was detected. Note that \emph{winRadius} does not necessarily correspond to the radius
#' of the tree's crown.
#'
#' @examples
#' # Set function for determining variable window radius
#' winFunction <- function(x){x * 0.06 + 0.5}
#'
#' # Set minimum tree height (treetops below this height will not be detected)
#' minHgt <- 2
#'
#' # Detect treetops in demo canopy height model
#' ttops <- vwf(CHMdemo, winFunction, minHgt)
#'
#' @seealso \code{\link{mcws}} \code{\link{sp_summarise}}
#'
#' @export

vwf <- function(CHM, winFun, minHeight = NULL, warnings = TRUE, minWinNeib = "queen", IDfield = "treeID"){

  ### CHECK INPUTS ----

  if("RasterLayer" %in% class(CHM)) CHM <- terra::rast(CHM)

  # Check for valid inputs for 'minWinNeib'
  if(!minWinNeib %in% c("queen", "rook")) stop("Invalid input for 'minWinNeib'. Set to 'queen' or 'rook'")

  # Check for unprojected rasters
  CHM_crs <- terra::crs(CHM)
  CHM_cs <- regmatches(CHM_crs, gregexpr("(?<=CS\\[).*?(?=,)", CHM_crs, perl=T))[[1]]
  if(warnings && length(CHM_cs) > 0 && !CHM_cs == "Cartesian") warning(
    "Detected coordinate system: '", CHM_cs ,"'.\n",
    "It is recommended that the CHM be projected using a cartesian coordinate system"
  )

  # Round out CHM resolution to fifth decimal and check that CHM has square cells.
  # Rounding is necessary since a lack of precision in CHM cell size call cause the
  # 'focalWeight' function to misbehave
  res_round <- round(terra::res(CHM), 5)
  if(res_round[1] != res_round[2]) stop("Input 'CHM' does not have square cells")
  if(res_round[1] == 0) stop("The map units of the 'CHM' are too small")

  # Ensure that 'minHeight' argument is given a positive value
  if(!is.null(minHeight) && minHeight <= 0) stop("Minimum canopy height must be set to a positive value.")

  # Get range of CHM values
  CHM_rng <- terra::minmax(CHM, compute = TRUE)[,1, drop = TRUE]

  # Check if CHM has usable values
  if(any(!is.finite(CHM_rng))) stop("Could not compute min/max range of CHM. The CHM may contain unusable values.")


  ### APPLY MINIMUM CANOPY HEIGHT ----

  if(!is.null(minHeight)){

    if(minHeight >= CHM_rng["max"]) stop("'minHeight' is set to a value higher than the highest cell value in 'CHM'")

    # Mask sections of CHM that are lower than 'minHeight'
    if(minHeight > CHM_rng["min"]){

      CHM[CHM < minHeight] <- NA
      CHM_rng["min"] <- minHeight
    }
  }


  ### CREATE WINDOWS ----

  # Here, the variably sized windows used for detecting trees are "pre-generated". First, a series of 'win_radii'
  # is generated, representing all the sizes the windows can take based on the range of potential values returned
  # by 'winFun'. These radii are then converted to binary matrices, where values of 1 represent the circular shape
  # of each window. These matrices are then converted to vectors and

  # Generate a list of radii
  seq_floor   <- .rounder(winFun(CHM_rng["min"]), interval = res_round[1], direction = "down")
  seq_ceiling <- .rounder(winFun(CHM_rng["max"]), interval = res_round[1], direction = "up")
  if(is.infinite(seq_floor)) seq_floor <- 0 # Watch out for parabola!
  win_radii <- seq(seq_floor, seq_ceiling, by = res_round[1])

  # Remove radii that are smaller than the CHM's resolution
  win_radii <- win_radii[win_radii >= res_round[1]]
  if(warnings && length(win_radii) == 0){
    warning(
      "The maximum window radius computed with 'winFun' is smaller than the CHM's resolution\n",
      "A 3x3 cell search window will be uniformly applied\n",
      "Use a higher resolution 'CHM' or adjust 'winFun' to produce wider dynamic windows"
    )
    win_radii <- res_round[1]
  }

  # Calculate the dimensions of the largest matrix to be created from the generated list of radii.
  # Note that it needs to be an uneven integer
  win_diam <- ceiling((max(win_radii) / res_round[1]) * 2)
  if (win_diam %% 2 == 0) win_diam <- win_diam + 1

  # Check if input formula will yield a particularly wide window diameter
  if(warnings && win_diam > 100) warning(
    "Input function for 'winFun' yields a window diameter of ",  win_diam, "which is particularly large.\n",
    "Adjusting the 'winFun' function is recommended."
  )

  # Convert radii into windows
  windows <- lapply(win_radii, function(radius){

    # Based on the unit size of the input CHM and a given radius, this function will create a matrix whose non-zero
    # values will form the shape of a circular window
    win_mat <- terra::focalMat(terra::rast(resolution = res_round), radius, type="circle")

    # Apply Queen's neighborhood if circle is 3x3
    if(nrow(win_mat) == 3 && minWinNeib == "queen") win_mat[] <- 1

    # Pad the window to the size of the biggest matrix created from the list of radii
    win_pad <- terra::extend(terra::rast(win_mat), (win_diam - ncol(win_mat)) /2, fill = 0)

    # The matrix values are then transformed into a vector
    win_vec <- as.vector(win_pad != 0)

    return(win_vec)

  })
  names(windows) <- win_radii


  ### APPLY VWF FUNCTION ----

  # Apply local maxima-finding function to raster
  local_max_ras <- terra::focal(
    CHM,
    matrix(1, win_diam, win_diam),
    fun     = .variable_window,
    windows = windows,
    winFun  = winFun)

  # Convert to points
  local_max_pts <- sf::st_as_sf(terra::as.points(local_max_ras, na.rm = TRUE, values = TRUE))
  names(local_max_pts)[1] <- 'height'

  # Add 'winRadius' and ID field
  local_max_pts[["winRadius"]] <- winFun(local_max_pts[["height"]])
  local_max_pts[[IDfield]] <- 1:nrow(local_max_pts)
  local_max_pts <- local_max_pts[,c(IDfield, "height", "winRadius", "geometry")]

  ### RETURN OUTPUT ----

  return(local_max_pts)

}


.variable_window <- function(x, windows, winFun, ...){

  # Locate central value in the moving window.
  centralValue <- x[length(x) / 2 + 0.5]

  # If central value is NA, then return NA.
  if(is.na(centralValue)){

    return(NA)

  }else{

    # Calculate the expected crown radius.
    radius <- winFun(centralValue)

    # Retrieve windows size closest to radius
    window <- windows[[which.min(abs(as.numeric(names(windows)) -  radius))]]

    # If the central value is the highest value within the variably-sized window (i.e.: local maxima), return 1. If not, return 0.
    return(if(max(x[window], na.rm = TRUE) == centralValue) centralValue else NA)
  }
}

.rounder <- function(value, interval, direction){

  if(direction == "up")   return(interval * ceiling(value / interval))
  if(direction == "down") return(interval * floor(  value / interval))
}


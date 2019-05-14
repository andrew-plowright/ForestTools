#' Grey level covariance matrix
#'
#' Generate textural metrics for a segmented raster using grey level covariance matrices (GLCM).
#' Implements the \code{glcm} function from the \link[radiomics:glcm]{radiomics} package.
#'
#' @param segs RasterLayer. A segmented raster. Cell values should be equal to segment numbers
#' @param image RasterLayer. A single-band raster layer from which texture is measured
#' @param n_grey integer. Number of grey levels the image should be quantized into
#'
#' @return data.frame
#'
#' @examples
#' \dontrun{
#' # Generate raster segments
#' segs <- mcws(kootenayTrees, kootenayCHM, minHeight = 0.2, format = "raster")
#'
#' # Get textural metrics for ortho's red band
#' tex <- glcm(segs, kootenayOrtho[[1]])
#' }
#'
#' @export

glcm <- function(segs, image, n_grey = 4){

  if(raster::nlayers(image) > 1) stop("'image' should have a single band")

  if(!raster::compareRaster(segs, image, extent=TRUE, rowcol=TRUE, crs=TRUE, res = TRUE, orig = TRUE)){
    stop("'segs' and 'image' rasters to not match extent, CRS or resolution")
  }

  if(raster::cellStats(image, "min") < 0){
    warning("Cannot compute GLCM metrics for segments containing negative values")
  }

  # Get image extent, resolution and dimensions
  e = raster::extent(image)
  r = raster::res(image)
  d = dim(image)

  # Convert image to data.frame and split according to segment values
  M = raster::as.data.frame(image, xy = TRUE)
  G = segs[]
  data.table::setDT(M)
  H = split(M, G)

  # Compute GLCM texture metrics for each segment
  segGLCM = do.call(rbind, lapply(H, function(x)
  {
    coords    = x[,1:2]
    data      = x[,3, drop = FALSE]
    offset    = c(min(coords$x), min(coords$y))
    cellsize  = r
    celldim   = (c(max(coords$x), max(coords$y)) - c(min(coords$x), min(coords$y)))/cellsize + 1
    topology  = sp::GridTopology(offset, cellsize, celldim)
    sp        = sp::SpatialPixelsDataFrame(coords, data, grid = topology)
    m         = as.matrix(sp)

    if(any(dim(m) > 2))
      tryCatch({ radiomics::calc_features(radiomics::glcm(m, n_grey = n_grey))}, error = function(e) return(NA))
    else
      NA
  }))

  # Add segment IDs
  cbind(treeID = as.integer(as.character(levels(factor(G)))), segGLCM)

}



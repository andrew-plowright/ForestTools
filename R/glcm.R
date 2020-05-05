#' Grey level covariance matrix
#'
#' Generate textural metrics for a segmented raster using grey level covariance matrices (GLCM).
#' Implements the \code{glcm} function from the \link[radiomics:glcm]{radiomics} package.
#'
#' @param segs RasterLayer. A segmented raster. Cell values should be equal to segment numbers
#' @param image RasterLayer. A single-band raster layer from which texture is measured
#' @param n_grey integer. Number of grey levels the image should be quantized into
#' @param clusters integer. Number of clusters to use during parallel processing
#' @param showprog logical. Display progress in terminal
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

glcm <- function(segs, image, n_grey = 32, clusters = 1, showprog = FALSE){

  if(raster::nlayers(image) > 1) stop("'image' should have a single band")

  if(!raster::compareRaster(segs, image, extent=TRUE, rowcol=TRUE, crs=TRUE, res = TRUE, orig = TRUE)){
    stop("'segs' and 'image' rasters to not match extent, CRS or resolution")
  }

  if(raster::cellStats(image, "min") < 0){
    stop("Cannot compute GLCM metrics for segments containing negative values")
  }

  # Get image resolution
  r = raster::res(image)

  # Convert image to data.frame and split according to segment values
  M = raster::as.data.frame(image, xy = TRUE)
  G = segs[]
  H = split(M, G)

  # Create vector for storing error messages
  err <- c()

  # Create worker function
  worker <- function(h){

    # Create topology for segment
    coords    = h[,1:2]
    offset    = c(min(coords$x), min(coords$y))
    segdim    = (c(max(coords$x), max(coords$y)) - c(min(coords$x), min(coords$y)))/r + 1
    topology  = sp::GridTopology(offset, r, segdim)

    # Segment as matrix
    seg = as.matrix(sp::SpatialPixelsDataFrame(coords, h[,3, drop = FALSE], grid = topology))

    # Try calculating GLCM metrics
    tryCatch({

      suppressMessages(radiomics::calc_features(radiomics::glcm(seg, n_grey = n_grey)))

      # If calculating GLCM failed, return empty data.frame and save error message
    }, error = function(e){

      err <<- c(err, e$message)
      data.frame(NA)

    })
  }


  # Progress bar
  paropts <- if(showprog){

    pb <- progress::progress_bar$new(
      format = "Progress [:bar] Tree :current/:total. ETA: :eta",
      total = length(H),
      width = 80,
      show_after = 0)
    pb$tick(0)

    list(progress = function(n) pb$tick())
  }

  # Create 'foreach' statement
  fe <- foreach::foreach(H = H, .options.snow = paropts)

  # Apply worker function (serial)
  segGLCM <- do.call(plyr::rbind.fill, if(clusters == 1){

    fe %do% {

      result <- worker(H)
      if(showprog) pb$tick()
      return(result)
    }

  # Apply worker function (parallel)
  }else{

    cl <- parallel::makeCluster(clusters)
    doSNOW::registerDoSNOW(cl)
    on.exit(parallel::stopCluster(cl))

    fe %dopar% worker(H)

  })

  # Remove column created by empty segments
  segGLCM$NA. <- NULL

  # Report reasons for GLCM failure
  if(length(err) > 0){

    errTable <- table(err)

    warning(paste(c("Generating GLCM metrics failed for", length(err), "segments:\n",
                    paste("  ", errTable, "segment(s):", names(errTable), "\n")), collapse = " "))
  }

  # Add segment IDs
  treeID <- as.integer(as.character(levels(factor(G))))
  cbind(treeID, segGLCM)

}



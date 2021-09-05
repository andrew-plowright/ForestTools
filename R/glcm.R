#' Grey-Level Co-Occurrence Matrix
#'
#' Generate textural metrics for a segmented raster using Grey-Level Co-Occurrence Matrices (GLCM). It will return a series of GLCM statistics
#' for each segment (\code{segs}) based on an underlying single-band raster image (\code{image}) in the form of a data.frame.
#'
#' The underlying C++ code for computing GLCMs and their statistics was originally written by Joel Carlson for the
#' defunct [radiomics](https://github.com/cran/radiomics) library. It has been reused here with permission from the author.
#'
#' @param segs RasterLayer. A segmented raster. Cell values should be equal to segment numbers
#' @param image RasterLayer. A single-band raster layer from which texture is measured
#' @param n_grey integer. Number of grey levels the image should be quantized into
#' @param angle integer. Angle at which GLCM will be calculated. Valid inputs are 0, 45, 90, or 135
#' @param clusters integer. Number of clusters to use during parallel processing
#' @param showprog logical. Display progress in terminal
#' @param roundCoords integer. Errors in coordinate precision can trigger errors in this function. Internally, the coordinates
#' are rounded to this decimal place. Default value of 4 decimals.
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
#' @references Parmar, C., Velazquez, E.R., Leijenaar, R., Jermoumi, M., Carvalho, S., Mak, R.H., Mitra, S., Shankar, B.U., Kikinis, R., Haibe-Kains, B. and Lambin, P. (2014).
#' \emph{Robust radiomics feature quantification using semiautomatic volumetric segmentation. PloS one, 9}(7)
#'
#' @export
#'
#' @importFrom foreach %do%
#' @importFrom foreach %dopar%

glcm <- function(segs, image, n_grey = 32, angle = 0, clusters = 1, showprog = FALSE, roundCoords = 4){

  if(raster::nlayers(image) > 1) stop("'image' should have a single band")

  if(!raster::compareRaster(segs, image, extent=TRUE, rowcol=TRUE, crs=TRUE, res = TRUE, orig = TRUE)){
    stop("'segs' and 'image' rasters to not match extent, CRS or resolution")
  }

  if(raster::cellStats(image, "min") < 0){
    stop("Cannot compute GLCM metrics for segments containing negative values")
  }

  # Create an empty data.frame
  emptyRow <- .GLCMstats(matrix())
  emptyRow[] <- NA

  # Get image resolution
  r = round(raster::res(image), roundCoords)

  # Convert image to data.frame and split according to segment values
  M = raster::as.data.frame(image, xy = TRUE)
  G = segs[]
  H = split(M, G)

  # Return empty data.frame if there are no segments
  if(length(H) == 0) return(cbind(treeID = integer(), emptyRow[-1,]))

  # Error counts
  errCount <- c(noDim = 0, allNA = 0)

  # Create worker function
  worker <- function(h){

    # Create topology for segment
    coords    = round(h[,1:2], roundCoords)
    offset    = c(min(coords$x), min(coords$y))
    segdim    = round((c(max(coords$x), max(coords$y)) - c(min(coords$x), min(coords$y)))/r + 1, roundCoords)
    topology  = sp::GridTopology(offset, r, segdim)

    # Segment as matrix
    seg = as.matrix(sp::SpatialPixelsDataFrame(coords, h[,3, drop = FALSE], grid = topology))

    # If segment has any missing dimensions, don't calculate
    if(any(dim(seg) == 0)){

      errCount["noDim"] <<- errCount["noDim"] + 1
      emptyRow

    # If segment contains all NA, don't calculate
    }else if(all(is.na(seg))){

      errCount["allNA"] <<- errCount["allNA"] + 1
      emptyRow

    # Otherwise, compute stats
    }else{

      .GLCMstats(.calcGLCM(seg, n_grey = n_grey, angle = angle))

    }
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
    doParallel::registerDoParallel(cl)
    on.exit(parallel::stopCluster(cl))

    fe %dopar% worker(H)

  })

  # Remove column created by empty segments
  segGLCM$NA. <- NULL

  # Report reasons for GLCM failure
  if(errCount["noDim"] > 0){
    warning("Could not calculate GLCM stats for ", errCount["noDim"], " segment(s) due to one or more image dimensions being equal to 0")
  }
  if(errCount["allNA"] > 0){
    warning("Could not calculate GLCM stats for ", errCount["allNA"], " segment(s) having no values")
  }


  # Add segment IDs
  treeID <- as.integer(as.character(levels(factor(G))))

  # Return result
  cbind(treeID, segGLCM)
}

#' Get GLCM statistics for a single unsegmented image
#'
#' @param img matrix or raster. Input image
#' @param n_grey integer. Number of grey levels used to discretize image
#' @param angle integer. Angle at which GLCM will be calculated. Valid inputs are 0, 45, 90, or 135
#' @param d numeric. Distance for calculating GLCM
#'
#' @export

glcm_img <- function(img, n_grey = 32, angle = 0, d = 1, normalize = TRUE){

  ### CHECK INPUTS ----
  if("RasterLayer" %in% class(img)){
    img <- raster::as.matrix(img)
  }else if(!"matrix" %in% class(img)){
    stop("Input image must be of class 'matrix' or 'RasterLayer'")
  }

  if(any(dim(img) == 0)) stop("Input image must contain values")
  if(any(is.na(img))) stop("Input image cannot have NA values")
  if(any(img < 0)) stop("Input image cannot have negative values")

  # Compute GLCM matrix
  img_glcm <- .calcGLCM(img, n_grey = n_grey, angle = angle, d = d, normalize = normalize)

  # Calculate GLCM stats
  stats_glcm <- .GLCMstats(img_glcm)

  return(stats_glcm)

}

#' Calculate GLCM
#'
#' Some notes about this  function:
#' 1. Input should be a matrix
#' 2. Shouldn't receive negative values
#' 3. Shouldn't receive all NA values
#' 4. Shouldn't be an empty matrix (i.e.: nrow = 0, ncol = 0)
#' 5. 'n_grey' shouldn't be larger than the number of unique values
#'
#' @param data matrix. Input image
#' @param n_grey integer. Number of grey levels used to discretize image
#' @param angle integer. Angle at which GLCM will be calculated. Valid inputs are 0, 45, 90, or 135
#' @param d numeric. Distance for calculating GLCM
#' @param normalize boolean. Normalize output if TRUE

.calcGLCM <- function(data, n_grey, angle, d = 1, normalize = TRUE){

  data <- .discretizeImage(data, n_grey = n_grey)

  unique_vals <- sort(unique(c(data)))

  #the value of 0 is reserved for NAs in the matrix,
  #if there are any 0's in the DF, add 1 to all values
  #original values will be replaced after
  if(is.element(0, data)) data <- data + 1

  #Convert All NAs to 0
  data[is.na(data)] <- 0


  if(identical(angle, 0)){

    counts <- glcm0(data, n_grey = max(data), d)

  } else if (identical(angle, 45)){
    counts <- glcm45(data, n_grey = max(data), d)

  } else if (identical(angle, 90)){
    counts <- glcm90(data, n_grey = max(data), d)

  } else if (identical(angle, 135)){
    counts <- glcm135(data, n_grey = max(data), d)

  } else {
    stop("angle must be one of '0', '45', '90', '135'.")
  }

  #Row 1 and Col 1 hold NA values, remove them
  counts <- counts[-1, -1]

  #Situation where matrix is composed of a single NA
  if(length(counts) == 0){
    counts

  }

  #Replace proper values in column and row names
  #Two situations:
  #1. No zeroes were present, thus nothing was added
  #2. One was added to all entries because there were zeros in the matrix

  if(is.matrix(counts)){

    if(dim(counts)[1] == max(unique_vals)){ #ie. 1 wasn't added
      counts <- counts[unique_vals, unique_vals]
      #counts <- counts[which(rownames(counts) %in% unique_vals), which(colnames(counts) %in% unique_vals)]

    } else if (dim(counts)[1] == max(unique_vals)+1) {
      #counts <- counts[which((as.numeric(rownames(counts)) - 1) %in% unique_vals), which((as.numeric(colnames(counts)) - 1) %in% unique_vals)]
      counts <- counts[unique_vals + 1, unique_vals + 1]
    }
  }

  if(!is.matrix(counts)) {
    #Edge case where only a single grey value present - leads to a numeric, rather than a matrix
    #Therefore case to 1x1 matrix
    counts <- matrix(counts)
  }

  rownames(counts) <- colnames(counts) <- unique_vals

  #GLCMs should be symmetrical, so the transpose is added
  counts <- counts + t(counts)

  #Normalize
  if(normalize){

    count_sum <- sum(counts)

    if(count_sum > 0){
      counts <- counts/count_sum
    }
  }

  return(counts)

}

#' Calculate stats for GLCM
#'
#' @param data matrix. GLCM computed using '.calcGLCM'

.GLCMstats <- function(data){

  #Set up allowed features

  stats_list <- list(
    "glcm_mean", "glcm_variance", "glcm_autoCorrelation",
    "glcm_cProminence", "glcm_cShade", "glcm_cTendency",
    "glcm_contrast", "glcm_correlation", "glcm_differenceEntropy",
    "glcm_dissimilarity", "glcm_energy", "glcm_entropy",
    "glcm_homogeneity1", "glcm_homogeneity2", "glcm_IDMN",
    "glcm_IDN", "glcm_inverseVariance", "glcm_maxProb",
    "glcm_sumAverage", "glcm_sumEntropy", "glcm_sumVariance"
  )

  feature_df <- data.frame(lapply(stats_list, function(f) tryCatch(get(f)(data),
                                                                     error=function(cond) return(NA),
                                                                     warning=function(cond) return(NA))))
  colnames(feature_df) <- stats_list
  return(feature_df)
}


.discretizeImage <- function(data, n_grey){

  l_unique <- length(unique(c(data)))

  if(n_grey >= l_unique){

    return(data)

  }else{

    discretized <- cut(
      data,
      breaks = seq(min(data, na.rm = TRUE), max(data, na.rm = TRUE), length.out=(n_grey + 1)),
      labels = seq(1, n_grey, 1),
      include.lowest = TRUE,
      right  = FALSE)

    return(matrix(as.numeric(discretized), nrow=nrow(data)))

  }
}

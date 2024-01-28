#' Grey-Level Co-Occurrence Matrix
#'
#' Generate textural metrics using Grey-Level Co-Occurrence Matrices (GLCM). Can be applied to an entire or image or, if a coterminous
#' raster of segments is provided, GLCM can be calculated for each segment.
#'
#' @param image SpatRaster. A single-band raster layer from which texture is measured
#' @param segs SpatRaster. A segmented raster. Cell values should be equal to segment numbers. If \code{segs} are not provided,
#' GLCM will be calculated for the entire image.
#' @param n_grey integer. Number of grey levels into which the image will be discretized
#' @param angle integer. Angle at which GLCM will be calculated. Ex.: `c(0,1)`
#' @param discretize_range numeric. Vector of two values indicating the minimum and maximum input values for discretizing the image.
#' This can be useful when processing tiles of a larger image, for which you may want to impose a consistent value range.
#'
#' @return data.frame
#'
#' @references Parmar, C., Velazquez, E.R., Leijenaar, R., Jermoumi, M., Carvalho, S., Mak, R.H., Mitra, S., Shankar, B.U., Kikinis, R., Haibe-Kains, B. and Lambin, P. (2014).
#' \emph{Robust radiomics feature quantification using semiautomatic volumetric segmentation. PloS one, 9}(7)
#'
#' @seealso \code{\link{mcws}}
#'
#' @examples
#' \dontrun{
#' library(terra)
#' library(ForestTools)
#'
#' chm <- rast(kootenayCHM)
#' image <- rast(kootenayOrtho)[[1]]
#'
#' # Generate raster segments
#' segs <- mcws(kootenayTrees, chm, minHeight = 0.2, format = "raster")
#'
#' # Get textural metrics for ortho's red band
#' tex <- glcm(image, segs)
#' }
#'
#' @export

glcm <- function(image, segs = NULL, n_grey = 32, angle = c(0,1), discretize_range = NULL){

  # Check image
  if(any(dim(image) == 0))     stop("'image' must contain usable values")
  if(terra::nlyr(image) > 1)   stop("'image' should have a single band")
  if(all(!is.finite(image[]))) stop("'image' must contain usable values")

  # Discretize image (this will replace NAs with 0)
  img_disc <- .discretize_rast(image, n_grey, discretize_range)

  # Compute GLCM for whole image
  if(is.null(segs)){

    # Convert to matrix
    img_mat <- terra::as.matrix(img_disc, wide = TRUE)

    # 'GLCMTextures' wants the range to be 0 to n_grey-1
    img_mat <- img_mat - 1

    # Compute GLCM
    seg_glcm <- GLCMTextures::make_glcm(img_mat, n_levels=n_grey, shift=angle, na.rm=TRUE)

    # Compute GLCM metrics
    out_glcm <- GLCMTextures::glcm_metrics(seg_glcm)

  }else{

    # Check segments
    if(all(!is.finite(segs[])))  stop("'segs' must contain usable values")
    terra::compareGeom(segs, image, res = TRUE)

    # Convert image to data.frame
    img_df = data.frame(
      terra::rowColFromCell(image, 1:(terra::ncell(img_disc))),
      val = img_disc[drop = TRUE]
    )
    names(img_df)[1:3] <- c("row", "col", "val")

    # Split according to segment values
    seg_dfs  <- split(img_df, segs[drop = TRUE])

    # Remove non-finite segments
    seg_dfs <- seg_dfs[!names(seg_dfs) %in% c("Inf", "-Inf", "NaN", "NA")]

    # Make empty row
    empty_row <- GLCMTextures::glcm_metrics(matrix())

    # Create worker function
    .glcm_by_seg <- function(seg_df){

      seg_df[,"row"] <- seg_df[,"row"] - min(seg_df[,"row"]) + 1
      seg_df[,"col"] <- seg_df[,"col"] - min(seg_df[,"col"]) + 1

      if(all(is.na(seg_df[["val"]]))) return(empty_row)

      # NOTE: any space around the segment is filled by 0s at this stage
      seg_mat <- as.matrix(Matrix::sparseMatrix(i = seg_df[,"row"], j =  seg_df[,"col"], x = seg_df[,"val"]))

      # 'sparseMatrix' doesn't allow 0s, so the original discretization will convert values to 1 to n_grey.
      # 'GLCMTextures', on the other hand, wants the range to be 0 to n_grey-1, and also wants NA values to be NA
      # Even if this involves extra steps, using 'sparseMatrix' is 10x faster than converting the data.frame
      # using 'terra'
      seg_mat[seg_mat == 0] <- NA
      seg_mat <- seg_mat - 1

      # Compute GLCM
      seg_glcm <- GLCMTextures::make_glcm(seg_mat, n_levels=n_grey, shift=angle, na.rm = T)

      # Compute GLCM metrics
      seg_metrics <- GLCMTextures::glcm_metrics(seg_glcm)

      return(seg_metrics)
    }

    # Apply worker to compute GLCMs
    out_glcm <- as.data.frame(do.call(rbind, lapply(seg_dfs, .glcm_by_seg)))

    # Test code for finding which segment is causing a bug
    # if(false){
    #   for(i in 1:length(seg_dfs)){
    #     cat(i,"\n")
    #     seg_df <- seg_dfs[[i]]
    #     .glcm_by_seg(seg_df)
    #   }
    # }

    # Return result
    row.names(out_glcm) <- names(seg_dfs)
  }

  return(out_glcm)
}


.discretize_rast <- function(image, n_grey, discretize_range = NULL){

  # Get range
  if(is.null(discretize_range)){
    img_range <- terra::minmax(image, compute = TRUE)
    img_min <- img_range[1,]
    img_max <- img_range[2,]
  }else{

    img_min <- min(discretize_range)
    img_max <- max(discretize_range)
  }

  if(img_min == img_max){

    # This neatly sets NA to 0 and everything else to 1
    new_values <- as.integer(is.finite(image[drop = TRUE]))

  }else{

    breaks <- seq(img_min, img_max, length.out=(n_grey + 1))

    levels <- seq(1, n_grey, 1)

    new_values <- as.integer(cut(image[drop = TRUE], breaks = breaks, labels = levels, include.lowest = TRUE, right = FALSE))
  }

  terra::setValues(image, new_values)
}

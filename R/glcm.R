#' Grey-Level Co-Occurrence Matrix
#'
#' Generate textural metrics using Grey-Level Co-Occurrence Matrices (GLCM). Can be applied to an entire or image or, if a coterminous
#' raster of segments is provided, GLCM can be calculated for each segment.
#'
#' The underlying C++ code for computing GLCMs and their statistics was originally written by Joel Carlson for the
#' defunct [radiomics](https://github.com/cran/radiomics) library. It has been reused here with permission from the author.
#'
#' @param image SpatRaster. A single-band raster layer from which texture is measured
#' @param segs SpatRaster. A segmented raster. Cell values should be equal to segment numbers. If \code{segs} are not provided,
#' GLCM will be calculated for the entire image.
#' @param n_grey integer. Number of grey levels into which the image will be discretized
#' @param angle integer. Angle at which GLCM will be calculated. Valid inputs are 0, 45, 90, or 135
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

glcm <- function(image, segs = NULL, n_grey = 32, angle = 0){

  # Check image
  if(any(dim(image) == 0))     stop("'image' must contain usable values")
  if(terra::nlyr(image) > 1)   stop("'image' should have a single band")
  if(all(!is.finite(image[]))) stop("'image' must contain usable values")

  # Discretize image (this will replace NAs with 0)
  img_disc <- .discretize_rast(image, n_grey)

  # Compute GLCM for whole image
  if(is.null(segs)){

    img_mat <- terra::as.matrix(img_disc, wide = TRUE)

    out_glcm <- .glcm_stats(.glcm_calc(img_mat, n_grey = n_grey, angle = angle))

  # Compute GLCM by segments
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
    empty_row <- .glcm_stats(matrix())
    empty_row[] <- NA

    # Create worker function
    .glcm_by_seg <- function(seg_df){

      seg_df[,"row"] <- seg_df[,"row"] - min(seg_df[,"row"]) + 1
      seg_df[,"col"] <- seg_df[,"col"] - min(seg_df[,"col"]) + 1

      # NOTE: any space around the segment is filled by 0s at this stage
      seg_mat <- as.matrix(Matrix::sparseMatrix(i = seg_df[,"row"], j =  seg_df[,"col"], x = seg_df[,"val"]))

      if(all(seg_mat == 0)) return(empty_row)

      .glcm_stats(.glcm_calc(seg_mat, n_grey = n_grey, angle = angle))
    }

    # Apply worker to compute GLCMs
    out_glcm <- do.call(plyr::rbind.fill, lapply(seg_dfs, .glcm_by_seg))

    # Return result
    row.names(out_glcm) <- names(seg_dfs)

  }

  return(out_glcm)
}

.glcm_calc <- function(seg_mat, n_grey, angle, d = 1){

  unique_vals <- sort(unique(c(seg_mat)))
  unique_vals <- unique_vals[unique_vals > 0]

  if(identical(angle, 0)){
    counts <- glcm0(seg_mat, n_grey = n_grey, d)

  } else if (identical(angle, 45)){
    counts <- glcm45(seg_mat, n_grey = n_grey, d)

  } else if (identical(angle, 90)){
    counts <- glcm90(seg_mat, n_grey = n_grey, d)

  } else if (identical(angle, 135)){
    counts <- glcm135(seg_mat, n_grey = n_grey, d)

  } else {
    stop("angle must be one of '0', '45', '90', '135'.")
  }

  # Row 1 and Col 1 hold NA values, remove them
  counts <- counts[-1, -1, drop = FALSE]

  # Situation where matrix is composed of a single NA
  if(length(counts) == 0) return(counts)

  counts <- counts[unique_vals, unique_vals, drop = FALSE]

  rownames(counts) <- colnames(counts) <- unique_vals

  # GLCMs should be symmetrical, so the transpose is added
  counts <- counts + t(counts)

  # Normalize
  counts <- counts/sum(counts)

  return(counts)

}

.glcm_stats <- function(data){

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

.discretize_rast <- function(rast, n_grey){

  # Get range
  img_range <- terra::minmax(rast, compute = TRUE)
  img_min <- img_range[1,]
  img_max <- img_range[2,]

  if(img_min == img_max){

    # This neatly sets NA to 0 and everything else to 1
    new_values <- as.integer(is.finite(rast[drop = TRUE]))

  }else{

    breaks <- seq(img_min, img_max, length.out=(n_grey + 1))

    levels <- seq(1, n_grey, 1)

    new_values <- as.integer(cut(rast[drop = TRUE], breaks = breaks, labels = levels, include.lowest = TRUE, right = FALSE))

    # Using cut replaced NaN and Inf with NAs
    new_values[is.na(new_values)] <- 0
  }

  terra::setValues(rast, new_values)
}

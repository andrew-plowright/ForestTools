#' Marker-Controlled Watershed Segmentation
#'
#' This function implements the \link[imager]{watershed} function to segment (i.e.: outline) crowns from a CHM (canopy height model).
#' Segmentation is guided by the point locations of treetops, typically detected using the \link{vwf} function.
#' See Meyer & Beucher (1990) for details on watershed segmentation.
#'
#' Crown segments are returned as either a \code{SpatRaster} or a \code{sf} (Simple Feature) class object,
#' as defined using the \code{format} argument. For many analytic purposes, it is preferable to have
#' crown outlines as polygons. However, polygonal crown maps take up significantly more disk space, and take
#' longer to process. It is advisable to run this function using a raster output first to review
#' results and adjust parameters.
#'
#' NOTE: when setting \code{format} to 'polygons', orphaned segments (i.e.: outlines without an associated treetop) will be removed.
#' This will NOT occur using 'raster' format. This issue will be resolved eventually but requires the watershed function to
#' be rewritten.
#'
#' @param treetops sf. The point locations of treetops in \code{sf} format.
#' @param CHM SpatRaster. Canopy height model in \code{SpatRaster} format. This should be the same CHM that was used to the detect the \code{treetops}.
#' @param minHeight numeric. The minimum height value for a \code{CHM} pixel to be considered as part of a crown segment.
#' All \code{CHM} pixels beneath this value will be masked out. Note that this value should be lower than the minimum
#' height of \code{treetops}.
#' @param format string. Format of the function's output. Can be set to either 'raster' or 'polygons'.
#' @param OSGeoPath character. Obsolete. Will be removed next version
#' @param IDfield character. Name of the field for storing the unique tree identifier
#'
#' @return Depending on the setting for \code{format}, this function will return a map of outlined
#' crowns as either a \code{SpatRaster} class object, in which distinct crowns are given a unique cell value, or a \code{sf} class object, in which each crown
#' is represented by a polygon.
#'
#' @references Meyer, F., & Beucher, S. (1990). Morphological segmentation. \emph{Journal of visual communication and
#' image representation, 1}(1), 21-46.
#'
#' @seealso \code{\link{vwf}}
#'
#' @examples
#' \dontrun{
#' library(terra)
#' library(ForestTools)
#'
#' chm <- rast(kootenayCHM)
#'
#' # Use variable window filter to detect treetops
#' ttops <- vwf(chm, winFun = function(x){x * 0.06 + 0.5}, minHeight = 2)
#'
#' # Segment tree crowns
#' segs <- mcws(ttops, chm, minHeight = 1)
#' }
#'
#' @export

mcws <- function(treetops, CHM, minHeight = 0, format = "raster", OSGeoPath = NULL, IDfield = "treeID"){

  if(!is.null(OSGeoPath)) message("'OSGeoPath' argument is now obsolete. Rasters are polygonized using the new 'terra' package now.")

  ### INPUTS ----

  # Convert 'raster' and 'sp' class types to 'terra' and 'sf'
  if(inherits(treetops, "SpatialPointsDataFrame")) treetops <- sf::st_as_sf(treetops)
  if(inherits(CHM, "RasterLayer")) CHM <- terra::rast(CHM)

  # Check classes for 'treetops' and 'CHM'
  if(!inherits(treetops, "sf") || sf::st_geometry_type(treetops, by_geometry = FALSE) != "POINT") stop("Invalid input: 'treetops' should be 'sf' class with 'POINT' geometry")
  if(!inherits(CHM, 'SpatRaster')) stop("Invalid input: CHM should be a 'SpatRaster' class")

  # Ensure that 'format' is set to either 'raster' or 'polygons'.
  if(!toupper(format) %in% c("RASTER", "POLYGONS", "POLYGON", "POLY")) stop("Invalid input: 'format' must be set to either 'raster' or 'polygons'")

  # Get maximum height and ensure that 'minHeight' does not exceed it
  CHM_max <-  terra::global(CHM, fun = max, na.rm = TRUE)[1,"max"]
  if(!is.finite(CHM_max)) stop("'CHM' does not contain any usable values.")
  if(minHeight > CHM_max) stop("'minHeight' is set higher than the highest cell value in 'CHM'")

  # Remove treetops that are not within the CHM's input extent, or whose height is lower than 'minHeight'
  treetop_heights <- terra::extract(CHM, treetops)[,2]
  treetops <- treetops[!is.na(treetop_heights) & treetop_heights >= minHeight,]
  if(length(treetops) == 0){stop("No usable treetops. Treetops are either outside of CHM's extent, or are located below the 'minHeight' value")}


  ### CHECK UNIQUE IDENTIFIER ----

  # Check existence of 'IDfield'
  if(!IDfield %in% names(treetops)) stop("Could not find ID field '", IDfield, "' in 'treetops' object")
  treetops[[IDfield]] <- as.integer(treetops[[IDfield]])
  if(any(treetops[[IDfield]] == 0)) stop("'ID field cannot be equal to 0")
  if(any(is.na(treetops[[IDfield]]))) stop("ID field cannot contain NA values")
  if(any(duplicated(treetops[[IDfield]]))) warning("ID field cannot have duplicated values")


  ### APPLY WATERSHED SEGMENTATION ----

  # Create NA mask
  CHM_mask <- CHM < minHeight
  CHM_mask[is.na(CHM)] <- TRUE

  # Replace NAs temporarily with 0s (the 'imager' functions cannot handle NA values)
  CHM[CHM_mask] <- 0

  # Convert treetops to a raster
  treetops_ras <- terra::rasterize(treetops, CHM, field = IDfield, background = 0)

  # Convert data to 'img' files
  CHM_img   <- imager::as.cimg(terra::as.matrix(CHM, wide = TRUE))
  ttops_img <- imager::as.cimg(terra::as.matrix(treetops_ras, wide = TRUE))

  # Apply watershed function
  ws_img <- imager::watershed(ttops_img, CHM_img)

  # Convert watershed back to raster
  ws_ras <- terra::rast(as.matrix(ws_img), extent = terra::rast(CHM), crs = terra::crs(CHM))
  ws_ras[CHM_mask] <- NA


  ### RETURN POLYGONS ----

  if(toupper(format) %in% c("POLYGONS", "POLYGON", "POLY")){

    # Convert raster to polygons
    polys <- sf::st_as_sf(terra::as.polygons(ws_ras, dissolve = TRUE))

    # Cast to MULTIPOLYGONS (this avoids introducing weird stuff like GEOMETRY COLLECTION)
    polys <- sf::st_cast(polys, "MULTIPOLYGON")

    # Split apart multi polygons
    polys <- sf::st_cast(polys, "POLYGON", warn = FALSE)

    if(nrow(polys) == 0) stop("No segments created")

    names(polys)[1] <- IDfield
    row.names(polys) <- 1:nrow(polys)

    # Perform spatial overlay, transfer data from treetops to polygons
    polys_out <- polys[lengths(sf::st_intersects(polys, treetops)) > 0,]

    # Remove polygons with no associated treetops
    polys_out  <- polys_out[!is.na(polys_out[[IDfield]]),]

    if(any(duplicated(polys_out[[IDfield]]))) stop("Multiple segments with same ID field. Check for duplicated treetops")

    return(polys_out)


  ### RETURN RASTER ----

  }else{

    # Remove "orphaned" segments. NOTE: The 'watershed' algorithm needs to be rewritten to avoid this whole thing
    #
    # NOTE: Currently deactivated cause it's too slow
    #
    # ws_patches <- terra::patches(ws_ras)
    # ws_patches_valid <-  unique(terra::extract(ws_patches, treetops)[,2])
    # ws_ras[!ws_patches %in% ws_patches_valid] <- NA

    return(ws_ras)
  }
}

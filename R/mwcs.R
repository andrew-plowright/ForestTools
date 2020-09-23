#' Marker-Controlled Watershed Segmentation
#'
#' Implements the \link[imager]{watershed} function to segment (i.e.: outline) crowns from a canopy height model.
#' Segmentation is guided by the point locations of treetops, typically detected using the \link{vwf} function.
#' See Meyer & Beucher (1990) for details on watershed segmentation.
#'
#' This function can return a crown map as either a \link[raster]{raster} or a \link[sp:SpatialPolygons]{SpatialPolygonsDataFrame},
#' as defined using the \code{format} argument. For most analytical purposes, it is preferable to have
#' crown outlines as polygons. However, polygonal crown maps take up significantly more disk space, and take
#' longer to process. It is advisable to run this function using a raster output first, in order to check
#' its results and adjust parameters.
#'
#' Using the 'polygons' output \code{format} provides the added benefit of transferring
#' treetop attributes (such as \emph{height}) to the newly created polygons. The area of each crown will also
#' automatically be calculated and added to the polygons' data under the \emph{crownArea} field. Furthermore,
#' "orphaned" segments (i.e.: outlines without an associated treetop) will be removed when
#' \code{format} is set to 'polygons'.
#'
#' By default, polygonal crown outlines are produced internally using the the \code{rasterToPolygons} function from
#' the \link[raster]{raster} package. This function is problematic due to it being 1) very slow and 2) leaking memory
#' when applied to multiple datasets. An alternative is provided for users who've installed OSGeo4W and Python.
#' By setting the \code{OSGeoPath} path to the OSGeo4W installation directory (usually 'C:\\OSGeo4W64'), the function will
#' use the \emph{gdal_polygonize.py} GDAL utility to generate polygonal crown outlines instead.
#'
#' @param treetops \link[sp:SpatialPoints]{SpatialPointsDataFrame}. The point locations of treetops. The function will generally produce a
#' number of crown segments equal to the number of treetops.
#' @param CHM Canopy height model in \link[raster]{raster} format. Should be the same that was used to create
#' the input for \code{treetops}.
#' @param minHeight numeric. The minimum height value for a \code{CHM} pixel to be considered as part of a crown segment.
#' All \code{CHM} pixels beneath this value will be masked out. Note that this value should be lower than the minimum
#' height of \code{treetops}.
#' @param format string. Format of the function's output. Can be set to either 'raster' or 'polygons'.
#' @param OSGeoPath character. Optional path to the OSGeo4W installation directory. If both OSGeo4W and Python are installed,
#' this will enable the function to use a faster algorithm for producing polygonal crown outlines (see Details below).
#' @param verbose logical. Print processing progress to console.
#'
#' @return Depending on the argument set with \code{format}, this function will return a map of outlined
#' crowns as either a RasterLayer (see \link[raster]{raster}), in which distinct crowns
#' are given a unique cell value, or a \link[sp:SpatialPolygons]{SpatialPolygonsDataFrame}, in which each crown
#' is represented by a polygon.
#'
#' @references Meyer, F., & Beucher, S. (1990). Morphological segmentation. \emph{Journal of visual communication and
#' image representation, 1}(1), 21-46.
#'
#' @seealso \code{\link{vwf}} \code{\link{sp_summarise}} \code{\link[imager]{watershed}} \cr \cr
#' OSGeo4W download page: \url{https://trac.osgeo.org/osgeo4w/}
#'
#' @examples
#' \dontrun{
#' # Use variable window filter to detect treetops in demo canopy height model
#' ttops <- vwf(CHMdemo, winFun = function(x){x * 0.06 + 0.5}, minHeight = 2)
#'
#' # Set minimum tree crown height (should be LOWER than minimum treetop height)
#' minCrwnHgt <- 1
#'
#' # Use 'mcws' to outline tree crowns
#' segs <- mcws(ttops, CHMdemo, minCrwnHgt)
#' }
#'
#' @export

mcws <- function(treetops, CHM, minHeight = 0, format = "raster", OSGeoPath = NULL, verbose = FALSE){

  if(verbose) cat("Begun 'mcws' process at", format(Sys.time(), "%Y-%m-%d, %X"), "\n\n")

  ### GATE-KEEPER

    # Ensure that 'format' is set to either 'raster' or 'polygons'.
    if(!toupper(format) %in% c("RASTER", "POLYGONS", "POLYGON", "POLY")){stop("'format' must be set to either 'raster' or 'polygons'")}

    if(verbose) cat("..Checking inputs", "\n")

    # Get maximum height and ensure that 'minHeight' does not exceed it
    CHM.max <- suppressWarnings(raster::cellStats(CHM, "max"))
    if(is.infinite(CHM.max)){stop("Input CHM does not contain any usable values.")}
    if(minHeight > CHM.max){stop("'minHeight' is set higher than the highest cell value in \'CHM\'")}

    # Remove treetops that are not within the CHM's input extent, or whose height is lower than 'minHeight'
    raster::crs(CHM) <- raster::crs(treetops)
    treetopsHgts <- raster::extract(CHM, treetops)
    treetops <- treetops[!is.na(treetopsHgts) & treetopsHgts >= minHeight,]
    if(length(treetops) == 0){stop("No usable treetops. Treetops are either outside of CHM's extent, or are located elow the 'minHeight' value")}

  ### GENERATE UNIQUE TREE IDENTIFIER

    # If treetops do not already have a 'treeID', add one
    if(!"treeID" %in% names(treetops)){
      warning("No 'treeID' found for input treetops. New 'treeID' identifiers will be added to segments")

      treetops[["treeID"]] <- 1:length(treetops)

    # Otherwise, check for duplicate 'treeID'
    }else{
      if(any(treetops[["treeID"]] == 0)) stop("'treeID' cannot be equal to 0")
      if(any(duplicated(treetops[["treeID"]]))) warning("Duplicate 'treeID' identifiers detected")
    }


  ### APPLY WATERSHED SEGMENTATION

      if(verbose) cat("..Masking areas below minimum crown height", "\n")

      # Create NA mask
      CHM.mask <- is.na(CHM) | CHM < minHeight

      # Replace NAs temporarily with 0s (the 'imager' functions cannot handle NA values)
      CHM[CHM.mask] <- 0

      if(verbose) cat("..Seeding treetop locations", "\n")

      # Convert treetops to a raster
      ttops.ras <- raster::rasterize(treetops, CHM, "treeID", background = 0)

      # Convert data to 'img' files
      CHM.img <- imager::as.cimg(raster::as.matrix(CHM))
      ttops.img <- imager::as.cimg(raster::as.matrix(ttops.ras))

      if(verbose) cat("..Applying watershed segmentation algorithm", "\n")

      # Apply watershed function
      ws.img <- imager::watershed(ttops.img, CHM.img)

      # Convert watershed back to raster
      ws.ras <- raster::raster(vals = ws.img[,,1,1], nrows = nrow(CHM), ncols = ncol(CHM),
                       ext = raster::extent(CHM), crs = raster::crs(CHM))
      ws.ras[CHM.mask] <- NA

  ### CONVERT TO POLYGONS

      if(toupper(format) %in% c("POLYGONS", "POLYGON", "POLY")){

        if(verbose) cat("..Converting to segments to polygons (this could take a while)", "\n")

        # Convert raster to polygons
        if(is.null(OSGeoPath)){

          # Using 'raster' package...
          polys <- raster::rasterToPolygons(ws.ras)
          polys <- rgeos::gUnaryUnion(polys, id = polys[["layer"]])
          polys <- sp::disaggregate(polys)

        }else{

          # Using OSGeo....
          polys <- APfun::APpolygonize(ws.ras, OSGeoPath = OSGeoPath)
        }

        if(verbose) cat("..Matching polygons to treetops", "\n")

        # Perform spatial overlay, transfer data from treetops to polygons
        polys.out  <- sp::SpatialPolygonsDataFrame(polys, sp::over(polys, treetops))

        # Remove polygons with no associated treetops
        polys.out  <- polys.out[!is.na(polys.out[["treeID"]]),]

        if(verbose) cat("..Computing segment areas", "\n")

        # Set new field for crown areas
        if("crownArea" %in% names(polys.out)){
          i <- 1
          while(paste0("crownArea", i) %in% names(polys.out)) i <- i + 1
          crownArea <- paste0("crownArea", i)
          warning("Input data already has a 'crownArea' field. Writing new crown area values to the 'crownArea",i,"' field")
        }else{
          crownArea <- "crownArea"
        }

        # Compute crown areas
        polys.out[[crownArea]] <- rgeos::gArea(polys.out, byid = TRUE)

        if(verbose) cat("..Returning crown outlines as polygons\n\nFinished at:", format(Sys.time(), "%Y-%m-%d, %X"), "\n")
        return(polys.out)

      }else{

        if(verbose) cat("..Returning crown outlines as a raster\n\nFinished at:", format(Sys.time(), "%Y-%m-%d, %X"), "\n")
        return(ws.ras)
      }
}

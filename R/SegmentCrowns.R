#' SegmentCrowns
#'
#' Implements the \link[imager]{watershed} function to segment (i.e.: outline) crowns from a canopy height model.
#' Segmentation is guided by the point locations of treetops, typically detected using the \link{TreeTopFinder} function.
#' See Meyer & Beucher (1990) for details on watershed segmentation.
#'
#' This function can return a crown map as either a \link[raster]{raster} or a \link[sp]{SpatialPolygonsDataFrame},
#' which are defined using the \code{format} argument. For most analytical purposes, it is preferable to have
#' crown outlines as polygons. However, polygonal crown maps take up significantly more disk space, and take
#' much longer to process. It is advisable to run this function using a raster output first, in order to check
#' its results and adjust parameters.
#'
#' Although it is slower, using the 'polygons' output \code{format} provides the added benefit of transferring
#' treetop attributes (such as \emph{height}) to the newly created polygons. The area of each crown will also
#' automatically be calculated and added to the polygons' data under the \emph{crownArea} field. Furthermore,
#' "orphaned" segments (i.e.: outlines without an associated treetop) will be removed when
#' \code{format} is set to 'polygons'.
#'
#' @param treetops \link[sp]{SpatialPointsDataFrame}. The point locations of treetops. The function will generally produce a
#' number of crown segments equal to the number of treetops.
#' @param CHM Canopy height model in \link[raster]{raster} format.
#' @param minHeight numeric. The minimum height value for a \code{CHM} pixel to be considered as part of a crown segment.
#' All \code{CHM} pixels beneath this value will be masked out. Note that this value should be lower than the minimum
#' height of \code{treetops}.
#' @param format string. Format of the function's ouput. Can be set to either 'raster' or 'polygons'.
#' @param verbose logical. Print processing progress to console.
#' @return Depending on the argument set with \code{format}, this function will return a map of outlined
#' crowns as either a RasterLayer (see \link[raster]{raster}), in which distinct crowns
#' are given a unique cell value, or a \link[sp]{SpatialPolygonsDataFrame}, in which each crown
#' is represented by a polygon.
#' @references Meyer, F., & Beucher, S. (1990). Morphological segmentation. \emph{Journal of visual communication and
#' image representation, 1}(1), 21-46.
#' @examples
#' # Use TreeTopFinder to detect treetops in demo canopy height model
#' ttops <- TreeTopFinder(CHMdemo, winFun = function(x){x * 0.06 + 0.5}, minHeight = 2)
#'
#' # Set minimum tree crown height (should be LOWER than minimum treetop height)
#' minCrwnHgt <- 1
#'
#' # Use SegmentCrowns to outline tree crowns
#' segs <- SegmentCrowns(ttops, CHMdemo, minCrwnHgt)
#' @seealso \code{\link{TreeTopFinder}} \code{\link{SpatialStatistics}} \code{\link[imager]{watershed}}
#' @export

SegmentCrowns <- function(treetops, CHM, minHeight = 0, format = "raster", verbose = TRUE){

  if(verbose) cat("Begun 'SegmentCrowns' process at", format(Sys.time(), "%Y-%m-%d, %X"), "\n\n")

  ### GATE-KEEPER

    # if(!is.null(treeID)){
    #   if(!treeID %in% names(treetops)) stop("Field for 'treeID': \"", treeID, "\", not found")
    #   if(class(treetops[[treeID]]) != "numeric") stop("Field for 'treeID' must be numeric")
    #   if(any(duplicated(treetops[[treeID]]))) stop("Duplicated IDs detected in the \"", treeID, "\", field")
    # }

    # Ensure that 'format' is set to either 'raster' or 'polygons'.
    if(!toupper(format) %in% c("RASTER", "POLYGONS", "POLYGON", "POLY")){stop("'format' must be set to either 'raster' or 'polygons'")}

    if(verbose) cat("..Checking inputs", "\n")

    # Get maximum height and ensure that 'minHeight' does not exceed it
    CHM.max <- suppressWarnings(max(raster::getValues(CHM), na.rm = TRUE))
    if(is.infinite(CHM.max)){stop("Input CHM does not contain any usable values.")}
    if(minHeight > CHM.max){stop("'minHeight' is set higher than the highest cell value in \'CHM\'")}

    # Remove treetops that are not within the CHM's input extent, or whose height is lower than 'minHeight'
    raster::crs(CHM) <- raster::crs(treetops)
    treetopsVals <- raster::extract(CHM, treetops)
    treetops <- treetops[!is.na(treetopsVals) & treetopsVals >= minHeight,]
    if(length(treetops) == 0){stop("No usable treetops. Treetops are either outside of CHM's extent, or are located elow the 'minHeight' value")}

  ### GENERATE UNIQUE TREE IDENTIFIER

    # If a field named 'treeNum' already exists, append a number to it so the original 'treeNum' won't be overwritten
    if("treeNum" %in% names(treetops)){
      i <- 1
      while(paste0("treeNum", i) %in% names(treetops)) i <- i + 1
      treeID <- paste0("treeNum", i)
    }else{
      treeID <- "treeNum"
    }

    # Create sequence if tree identifiers
    treetops[[treeID]] <- 1:length(treetops)

    # if(is.null(treeID)){
    #   treeID <- "treeNum"
    #   notree <- 0
    #   treetops[[treeID]] <- 1:length(treetops)
    # }else{
    #   notree <- max(treetops[[treeID]]) + 1
    # }

  ### APPLY WATERSHED SEGMENTATION

      if(verbose) cat("..Masking areas below minimum crown height", "\n")

      # Create NA mask
      CHM.mask <- is.na(CHM) | CHM < minHeight

      # Replace NAs temporarily with 0s (the 'imager' functions cannot handle NA values)
      CHM[CHM.mask] <- 0

      if(verbose) cat("..Seeding treetop locations", "\n")

      # Convert treetops to a raster
      ttops.ras <- raster::rasterize(treetops, CHM, "treeNum", background = 0)

      # Convert data to 'img' files
      CHM.img <- imager::as.cimg(raster::as.matrix(CHM))
      ttops.img <- imager::as.cimg(raster::as.matrix(ttops.ras))

      if(verbose) cat("..Applying watershed segmentation algorithm", "\n")

      # Apply watershed function
      ws.img <- imager::watershed(ttops.img, CHM.img)

      # Convert watershed back to raster
      ws.ras <- raster::raster(vals = ws.img[,,1,1], nrows = nrow(CHM), ncols =  ncol(CHM),
                       ext = raster::extent(CHM), crs = raster::crs(CHM))
      ws.ras[CHM.mask] <- NA

  ### CONVERT TO POLYGONS

      if(toupper(format) %in% c("POLYGONS", "POLYGON", "POLY")){

        if(verbose) cat("..Converting to segments to polygons (this could take a while)", "\n")

        # Convert raster to polygons
        polys <- raster::rasterToPolygons(ws.ras)
        polys <- rgeos::gUnaryUnion(polys, id = polys[["layer"]])

        if(verbose) cat("..Matching polygons to treetops", "\n")

        # Disaggregate multi-part polygons
        polys.dag <- sp::disaggregate(polys)

        # Perform spatial overlay, transfer data from treetops to polygons, and remove polygons with no associated treetops
        polys.over <- sp::over(polys.dag, treetops)
        polys.out <- sp::SpatialPolygonsDataFrame(polys.dag, subset(polys.over, select= which(names(polys.over) != treeID)))
        polys.out <- polys.out[match(treetops[[treeID]], polys.over[,treeID]),]

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

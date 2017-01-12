#' SegmentCrowns
#'
#' Implements the \link[imager]{watershed} function to segment crowns from a canopy height model. Segmentation is
#' guided by the point locations of treetops, typically detected using the \link{TreeTopFinder} function. See Meyer
#' & Beucher (1990) for details on watershed segmentation.
#'
#' @param treetops \link[sp]{SpatialPointsDataFrame}. The point locations of treetops. The function will generally produce a
#' number of crown segments equal to the number of treetops.
#' @param CHM Canopy height model. Either in \link[raster]{raster} format, or a path directing to a raster file. A character vector of multiple paths directing to a
#' tiled raster dataset can also be used.
#' @param minHeight numeric. The minimum height value for a \code{CHM} pixel to be considered as part of a crown segment.
#' All \code{CHM} pixels beneath this value will be masked out. Note that this value should be lower than the minimum
#' height of \code{treetops}.
#' @param maxCells numeric. If the number of raster cells for the \code{CHM} exceeds this value, the \link[TileManager]{TileScheme} function
#' will be applied to break apart the input into tiles to speed up processing.
#' @param tileBuffer numeric. If the function breaks the CHM into tiles for processing, an
#' overlapping spatial buffer is applied around each tile to prevent edge effects. The
#' \code{tileBuffer} argument defines the width of this buffer, and should be equal to half
#' the diameter of the widest expected tree crown.
#' @return A \link[raster]{raster} of crown segments. The \link[raster]{rasterToPolygons} function can be used to convert this into
#' polygons.
#' @references Meyer, F., & Beucher, S. (1990). Morphological segmentation. Journal of visual communication and image representation, 1(1), 21-46.
#' @examples
#' # Use TreeTopFinder to detect treetops in demo canopy height model
#' ttops <- TreeTopFinder(CHMdemo, winFun = function(x){x * 0.06 + 0.5}, minHeight = 2)
#'
#' # Set minimum tree crown height (should be LOWER than minimum treetop height)
#' minCrwnHgt <- 1
#'
#' # Use SegmentCrowns to outline tree crowns
#' segs <- SegmentCrowns(ttops, CHMdemo, minCrwnHgt)
#' @seealso \code{\link{TreeTopFinder}}
#' @export

SegmentCrowns <- function(treetops, CHM, minHeight = 0, maxCells = 2000000, tileBuffer = 20){

  ### GATE-KEEPER

    # Convert single Raster object or paths to raster files into a list of Raster objects
    CHM <- TileManager::TileInput(CHM, "CHM")

    # Get maximum height and ensure that 'minHeight' does not exceed it
    CHM.max <- max(sapply(CHM, function(tile) suppressWarnings(max(tile[], na.rm = TRUE))))
    if(is.infinite(CHM.max)){stop("Input CHM does not contain any usable values.")}
    if(minHeight > CHM.max){stop("\'minHeight\' is set higher than the highest cell value in \'CHM\'")}

    # Remove treetops that are not within the CHM's input extent
    totalExt <- rgeos::gUnaryUnion(sp::SpatialPolygons(
      lapply(1:length(CHM), function(tileNum){
        sp::spChFIDs(methods::as(raster::extent(CHM[[tileNum]]), "SpatialPolygons"), as.character(tileNum))@polygons[[1]]
      })))
    raster::crs(totalExt) <- raster::crs(treetops)
    treetops <- treetops[!is.na(sp::over(treetops,totalExt)),]
    if(length(treetops) == 0){stop("No input treetops intersect with CHM")}
    treetops[["treeNum"]] <- 1:length(treetops)

  ### PRE-PROCESS: MULTI-TILES CHECK

    # Detect/generate tiling scheme
    tiles <- TileManager::TileApply(CHM, maxCells = maxCells, tileBuffer = tileBuffer)

    # If input raster exceeds maximum number of cells, apply tiling scheme
    if(length(CHM) == 1 & raster::ncell(CHM[[1]]) > maxCells){

      CHM <- TileManager::TempTiles(CHM[[1]], tiles)
      on.exit(TileManager::removeTempTiles(), add = TRUE)
    }

  ### PROCESS

    # Create tiles
    seg.tiles <- lapply(1:length(CHM), function(tileNum){

      # Extract CHM tile and non-overlapping buffered extent
      CHM.tile <- CHM[[tileNum]]
      nbuff.tile <- tiles$nbuffPolygons[tileNum,]

      # Create NA mask
      CHM.mask <- is.na(CHM.tile) | CHM.tile < minHeight

      # Replace NAs temporarily with 0s (the 'imager' functions cannot handle NA values)
      CHM.tile[CHM.mask] <- 0

      # Convert treetops to a raster
      ttops.tile <- raster::rasterize(treetops, CHM.tile, "treeNum", background = 0)

      # Convert tiled data to 'img' files
      CHM.img <- imager::as.cimg(raster::as.matrix(CHM.tile))
      ttops.img <- imager::as.cimg(raster::as.matrix(ttops.tile))

      # Apply watershed function
      ws.img <- imager::watershed(ttops.img, CHM.img)

      # Convert watershed back to raster
      ws.ras <- raster::raster(vals = ws.img[,,1,1], nrows = nrow(CHM.tile), ncols =  ncol(CHM.tile),
                       ext = raster::extent(CHM.tile), crs = raster::crs(CHM.tile))
      ws.ras[CHM.mask] <- NA

      # Crop tile to non-overlapping buffered extent
      ws.ras.crop <- raster::crop(ws.ras, raster::extent(nbuff.tile))

      return(ws.ras.crop)
    })

    # Merge segment tiles
    if(length(seg.tiles) > 1){
      seg.tiles$fun <- max
      seg.mosaic <- do.call(raster::mosaic, seg.tiles)
    }else{
      seg.mosaic <- seg.tiles[[1]]
    }
    rm(seg.tiles)
    raster::crs(seg.mosaic) <- raster::crs(treetops)

  ### RETURN SEGMENTS
  return(seg.mosaic)
}

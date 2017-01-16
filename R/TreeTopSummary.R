#' Treetop Summary
#'
#' Summarization tool for calculating tree counts and tree height statistics within a given area
#'
#' @param treetops \link[sp]{SpatialPointsDataFrame}. The point location of a set of treetops. Typically
#' detected from a canopy height model using \code{\link{TreeTopFinder}}. Tree attributes, such as height
#' or crown size, should be stored within this object's \code{@@data} slot.
#' @param areas \link[sp]{SpatialPolygonsDataFrame}. An optional set of polygons corresponding to areas of
#' interest. Tree counts and statistics will be returned for each area.
#' @param grid RasterLayer (see \link[raster]{raster}) or numeric. Similar to the \code{areas} argument, using \code{grid}
#' will compute tree count and statistics according to a spatial grid. Grid size and placement can be defined
#' by using a \link[raster]{raster} object. If a single numeric value is used, the function will generate a
#' grid with a cell size equal to this value.
#' @param variables character. The names of tree attribute variables (stored in \code{treetops@data} slot).
#'  In addition to tree counts, the function will compute statistics (mean, median, standard deviation, minimum and
#' maximum) for each of these variables. Only numeric values are accepted.
#'
#' @return Tree count and, if any \code{variables} are supplied, tree attribute statistics. If no
#' \code{areas} or \code{grid} is supplied, the tree count and statistics are computed for the entire
#' \code{treetops} dataset, and returned as a 'data.frame' object. If \code{areas} are defined, an
#' identical \link[sp]{SpatialPolygonsDataFrame} will be returned, with all computed statistics appended
#' to the object's \code{@@data} slot. If a \code{grid} is defined, tree count will be returned as a RasterLayer,
#' with cell values equal to the number of trees in each cell. If a \code{grid} and \code{variables} are defined,
#' a RasterBrick (see \link[raster]{brick}) will be returned instead, with tree count and attribute statistics
#' stored as separate layers.
#'
#' @examples
#' # Load sample data
#' library(ForestTools)
#' library(sp)
#' data("kootenayTrees", "kootenayBlocks")
#'
#' # Get total tree count
#' TreeTopSummary(kootenayTrees)
#'
#' # Get total tree count and tree height statistics
#' TreeTopSummary(kootenayTrees, variables = "height")
#'
#' # Get tree count and height statistics for specific areas of interest
#' areaStats <- TreeTopSummary(kootenayTrees, areas = kootenayBlocks, variables = "height")
#'
#' # Plot according to tree count
#' plot(areaStats, col = heat.colors(3)[order(areaStats$TreeCount)])
#'
#' # Get tree count and height statistics for a 20 x 20 m spatial grid
#' gridStats <- TreeTopSummary(kootenayTrees, grid = 20, variables = "height")
#'
#' # Plot gridded tree count and statistics
#' plot(gridStats$TreeCount)
#' plot(gridStats$heightMax)
#'
#' @seealso \code{\link{TreeTopFinder}}
#' @importFrom stats median sd
#' @export

TreeTopSummary <- function(treetops, areas = NULL, grid = NULL, variables = NULL){

  ### GATEKEEPER

    if(class(treetops) != "SpatialPointsDataFrame") stop("Invalid input: \'treetops\' must be a SpatialPointsDataFrame")
    if(!is.null(areas) && !class(areas) %in% c("SpatialPolygonsDataFrame")) stop("Invalid input: \'areas\' must be a SpatialPolygonsDataframe object")
    if(!is.null(variables) && any(!variables %in% names(treetops))) stop("Invalid input: \'treetops\' does not contain variables: \'", paste(variables[!variables %in% names(treetops)], collapse = "\', \'"), "\'")
    if(!is.null(variables) && any(sapply(treetops@data[,variables], class) != "numeric")) stop("Invalid input: variables \'",paste(variables[sapply(treetops@data[,variables], class) != "numeric"], collapse = "\', \'") , "\' is/are non-numeric")
    if(!is.null(grid) && !class(grid) %in% c("RasterLayer", "numeric")) stop("Invalid input: \'grid\' must be a Raster object or a numeric value")
    if(!is.null(grid) & !is.null(areas)) stop("Cannot compute output for both \'areas\' and \'grid\'. Please define only one.")

  ### PRE-PROCESS: Set statistic functions

    statFuns <- c(mean, median, sd, min, max)
    names(statFuns) <-  c("Mean", "Median", "SD", "Min", "Max")

  ### PRE-PROCESS: Function for computing statistics

    treeStats <- function(trees){

      # Calculate tree count
      outStats <- length(trees)
      names(outStats) <- "TreeCount"

      # Compute variable statistics if required
      if(!is.null(variables)){
        outStats <- c(outStats, do.call(c, lapply(variables, function(variable){

          variableStats <- sapply(statFuns, function(statFun) statFun(trees[[variable]]))
          names(variableStats) <- paste0(variable, names(statFuns))

          return(variableStats)
        })))
      }

      return(outStats)
    }

  ### PROCESS: No areas are given

    if(is.null(areas) & is.null(grid)){

      outData <- data.frame(treeStats(treetops))
      colnames(outData) <- "Value"

      return(outData)
    }

  ### PROCESS: Area is a set of polygons

  if(class(areas) == "SpatialPolygonsDataFrame"){

    # Extract row names of overlapping polygons for each tree
    areas.treenames <- lapply(sp::over(areas, treetops, returnList = TRUE), row.names)

    # Compute statistics of each areea
    areas.data <- do.call(rbind, lapply(areas.treenames, function(area.treenames){

      # Check number of trees found in area
      if(length(area.treenames) > 0){

        # Extract trees within a given area and calculate stats
        areaStats <- treeStats(treetops[area.treenames,])

      }else{

        # Return NA values if no trees were found within area
        areaStats <- rep(NA, length(variables) * length(statFuns) + 1)
        names(areaStats) <- c("TreeCount", apply(expand.grid(variables, names(statFuns)), 1, paste, collapse = ""))
      }

      return(areaStats)
    }))

    # Attach data to SpatialPolygonsDataFrame
    areas@data <- cbind(areas@data, areas.data)

    if(all(is.na(areas.data))) warning("No treetops located within given areas")

    return(areas)
  }

  ### PROCESS: Grid is a numeric value

    if(class(grid) == "numeric"){

      # Use numeric value to create a gridded Raster object

      # Get extent of treetops
      treetops.ext <- raster::extent(treetops)

      # Create new extent that completely overlaps all treetops
      ras.ext.xmin <- treetops.ext@xmin
      ras.ext.ymax <- treetops.ext@ymax
      ras.ext.xmax <- APfun::AProunder(treetops.ext@xmax, interval = grid, direction = "up", snap = ras.ext.xmin)
      ras.ext.ymin <- APfun::AProunder(treetops.ext@ymin, interval = grid, direction = "down", snap = ras.ext.ymax)
      ras.ext <- raster::extent(ras.ext.xmin, ras.ext.xmax, ras.ext.ymin, ras.ext.ymax)

      # Create gridded raster
      grid <- raster::raster(ras.ext, res = c(grid, grid), vals = 0, crs = sp::proj4string(treetops))
    }

  ### PROCESS: Grid is a raster

    if(class(grid) == "RasterLayer"){

        # Compute tree count
        treetopsCount <- treetops
        treetopsCount@data <- data.frame(counter = rep(1, length(treetopsCount)))
        outRas <- raster::rasterize(treetopsCount, grid, field = "counter", fun = "count")
        names(outRas) <- "TreeCount"
        if(all(is.na(outRas[]))) warning("No treetops located within given grid")


        if(!is.null(variables)){

          # Compute gridded statistics
          statRas <- raster::brick(lapply(statFuns, function(statFun){
            raster::rasterize(treetops, grid, field = variables, fun = statFun)}))
          names(statRas) <- apply(expand.grid(variables, names(statFuns)), 1, paste, collapse = "")

          outRas <- raster::brick(outRas, statRas)
        }

        return(outRas)
    }
}



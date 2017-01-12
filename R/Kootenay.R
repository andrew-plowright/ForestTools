#' Kootenay forest - Canopy height model
#'
#' A canopy height model of a 1.5 hectare section of forest in the Kootenay mountains, in
#' British Columbia, Canada.
#'
#' @format A RasterLayer
#' \describe{Cell values are equal to canopy height above ground (in meters)}
#' @source Data acquired from a photogrammetric drone survey performed by Spire Aerobotics
#' on June 16th, 2016.
#' @seealso \link{kootenayTrees} \link{kootenayBlocks}
"kootenayCHM"

#' Kootenay forest - Dominant trees over 2 m
#'
#' Dominant trees from a 1.5 hectare section of forest in the Kootenay mountains, in
#' British Columbia, Canada. Trees were detected by applying the \code{\link{TreeTopFinder}}
#' function to the \link{kootenayCHM} raster dataset. Only trees over 2 m above ground
#' were detected.
#'
#' @format A \link[sp]{SpatialPointsDataFrame} with the following attributes:
#' \describe{
#'   \item{height}{height of the tree's apex, in meters above ground}
#'   \item{radius}{radius of the moving window (see \code{\link{TreeTopFinder}}) at
#'   the treetop's location}
#'   }
#' @seealso \link{kootenayCHM} \link{kootenayBlocks}
"kootenayTrees"

#' Kootenay forest - Cut blocks
#'
#' Boundaries of cut blocks within a 1.5 hectare section of forest in
#' the Kootenay mountains, in British Columbia, Canada. Each block contains trees of different
#' levels of maturity. Overlaps with \link{kootenayTrees} and \link{kootenayCHM}.
#'
#' @format A \link[sp]{SpatialPolygonsDataFrame} with the following attributes:
#' \describe{
#'   \item{BlockID}{numerical identifier for each block}
#'   \item{Shape_Leng}{length of polygon on meters}
#'   \item{Shape_Area}{area of polygon in square meters}
#'   }
#' @seealso \link{kootenayTrees} \link{kootenayCHM}
"kootenayBlocks"

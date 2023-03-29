#' Quesnel forest - Canopy height model
#'
#' A canopy height model of a 125 hectare section of forest in the Quesnel Timber Supply Area, in
#' British Columbia, Canada.
#'
#' @format PackedSpatRaster object
#' \describe{Cell values are equal to canopy height above ground (in meters)}
#' @source Data acquired from a photogrammetric drone survey performed by Spire Aerobotics
#' on September 15th, 2016.
#' @seealso \link{quesnelTrees} \link{quesnelBlocks}
"quesnelCHM"

#' Quesnel forest - Dominant trees over 2 m
#'
#' Dominant trees from a 125 hectare section of forest in the Quesnel Timber Supply Area, in
#' British Columbia, Canada. Trees were detected by applying the \code{\link{vwf}}
#' function to the \link{quesnelCHM} raster dataset. Only trees over 2 m above ground
#' were detected.
#'
#' @format Simple point feature collection with the following attributes:
#' \describe{
#'   \item{height}{height of the tree's apex, in meters above ground}
#'   \item{winRadius}{radius of the moving window (see \code{\link{vwf}}) at
#'   the treetop's location}
#'   }
#' @seealso \link{quesnelCHM} \link{quesnelBlocks}
"quesnelTrees"

#' Quesnel forest - Cut blocks
#'
#' Boundaries of cut blocks within a 125 hectare section of forest in the Quesnel Timber Supply Area,
#' in British Columbia, Canada. Each block contains trees of different
#' levels of maturity. Overlaps with \link{quesnelTrees} and \link{quesnelCHM}.
#'
#' @format Simple polygon feature collection with the following attributes:
#' \describe{
#'   \item{BlockID}{numerical identifier for each block}
#'   \item{Shape_Leng}{length of polygon on meters}
#'   \item{Shape_Area}{area of polygon in square meters}
#'   }
#' @seealso \link{quesnelTrees} \link{quesnelCHM}
"quesnelBlocks"

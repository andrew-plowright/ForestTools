#' Kootenay forest - Canopy height model
#'
#' A canopy height model of a 1.5 hectare section of forest in the Kootenay mountains, in
#' British Columbia, Canada.
#'
#' @format PackedSpatRaster object
#' \describe{Cell values are equal to canopy height above ground (in meters)}
#' @source Data acquired from a photogrammetric drone survey performed by Spire Aerobotics
#' on June 16th, 2016.
#' @seealso \link{kootenayTrees} \link{kootenayBlocks} \link{kootenayCrowns} \link{kootenayOrtho}
"kootenayCHM"

#' Kootenay forest - Dominant trees over 2 m
#'
#' Dominant trees from a 1.5 hectare section of forest in the Kootenay mountains, in
#' British Columbia, Canada. Trees were detected by applying the \code{\link{vwf}}
#' function to the \link{kootenayCHM} raster dataset. Only trees over 2 m above ground
#' were detected.
#'
#' @format Simple point feature collection with the following attributes:
#' \describe{
#'   \item{height}{height of the tree's apex, in meters above ground}
#'   \item{winRadius}{radius of the moving window (see \code{\link{vwf}}) at
#'   the treetop's location}
#'   }
#' @seealso \link{kootenayCHM} \link{kootenayBlocks} \link{kootenayCrowns} \link{kootenayOrtho}
"kootenayTrees"

#' Kootenay forest - Cut blocks
#'
#' Boundaries of cut blocks within a 1.5 hectare section of forest in
#' the Kootenay mountains, in British Columbia, Canada. Each block contains trees of different
#' levels of maturity. Overlaps with \link{kootenayTrees}, \link{kootenayCrowns}, \link{kootenayOrtho} and \link{kootenayCHM}.
#'
#' @format Simple polygon feature collection with the following attributes:
#' \describe{
#'   \item{BlockID}{numerical identifier for each block}
#'   \item{Shape_Leng}{length of polygon on meters}
#'   \item{Shape_Area}{area of polygon in square meters}
#'   }
#' @seealso \link{kootenayTrees} \link{kootenayCHM} \link{kootenayCrowns} \link{kootenayOrtho}
"kootenayBlocks"

#' Kootenay forest - Tree crowns
#'
#' Outlines of tree crowns corresponding to the \link{kootenayTrees} treetops. Generated using \link{mcws}.
#'
#' @format Simple polygon feature collection with the following attributes:
#' \describe{
#'   \item{height}{height of the tree's apex, in meters above ground. Inherited from \link{kootenayTrees}.}
#'   \item{winRadius}{radius of the moving window at the treetop's location. Inherited from \link{kootenayTrees}.}
#'   \item{crownArea}{area of crown outline in square meters}
#'   }
#' @seealso \link{kootenayTrees} \link{kootenayCHM} \link{kootenayBlocks} \link{kootenayOrtho}
"kootenayCrowns"



#' Kootenay forest - Orthomosaic
#'
#' An orthomosaic of a 1.5 hectare section of forest in the Kootenay mountains, in
#' British Columbia, Canada.
#'
#' @format PackedSpatRaster object
#' \describe{Cell values are equal to canopy height above ground (in meters)}
#' @source Data acquired from a photogrammetric drone survey performed by Spire Aerobotics
#' on June 16th, 2016.
#' @seealso \link{kootenayTrees} \link{kootenayBlocks} \link{kootenayCrowns} \link{kootenayCHM}
"kootenayOrtho"

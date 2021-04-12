
<!-- README.md is generated from README.Rmd. Please edit that file -->

## Forest Tools: Tools for analyzing remotely sensed forest data

**Authors:** Andrew Plowright<br/> **License:** GPL 3

[![Build
Status](https://travis-ci.org/andrew-plowright/ForestTools.svg?branch=master)](https://travis-ci.org/andrew-plowright/ForestTools)

The Forest Tools R package offers functions to analyze remotely sensed
forest data.

## Detect and segment trees

Individual trees can be detected and delineated using the combination of a
**variable window filter** algorithm (`vwf`) and **marker-controlled segmentation**
(`mcws`), both of which are applied to a rasterized **canopy height model (CHM)**.
CHMs are typically derived from aerial LiDAR or photogrammetric point clouds.

## Compute textural metrics

Currently, tools to detect dominant treetops (`vwf`) and outline
tree crowns (`mcws`) have been implemented, both of which are applied to a
rasterized **canopy height model (CHM)**, which is generally derived
from LiDAR or photogrammetric point clouds. A function to summarize the
height and count of treetops within user-defined geographical areas is
also available (`sp_summarise`).


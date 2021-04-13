
<!-- README.md is generated from README.Rmd. Please edit that file -->

## Forest Tools: Tools for analyzing remotely sensed forest data

**Authors:** Andrew Plowright<br/> **License:** GPL 3

[![Build
Status](https://travis-ci.org/andrew-plowright/ForestTools.svg?branch=master)](https://travis-ci.org/andrew-plowright/ForestTools)

The Forest Tools R package offers functions to analyze remotely sensed forest data.

## Detect and segment trees

Individual trees can be detected and delineated using the combination of the
**variable window filter**  (`vwf`) and **marker-controlled segmentation**
(`mcws`) algorithms, both of which are applied to a rasterized **canopy height model (CHM)**.
CHMs are typically derived from aerial LiDAR or photogrammetric point clouds.

## Compute textural metrics

Grey-Level Co-Occurrence Matrices (GLCMs) and their associated statistics can be computed for individual trees using a single-band
image and a segment raster (produced using `mcws`). The underlying code for these statistics was initially developed in the [radiomics](https://github.com/cran/radiomics) library by Joel Carlson, but it is no longer maintained so the code is used here with permission from the original author.

## Summarize forest information

A summary of the height and count of treetops within user-defined geographical areas can be created using `sp_summarise`.

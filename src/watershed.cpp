#include <Rcpp.h>
#define cimg_display 0
#include "CImg.h"

using namespace Rcpp;
using namespace cimg_library;

// [[Rcpp::export]]
NumericMatrix watershed_cpp(NumericMatrix im, NumericMatrix priority, bool fill_lines = true) {
  int rows = im.nrow(); // This is the 'height' (y)
  int cols = im.ncol(); // This is the 'width' (x)
  
  // Initialize CImg with dimensions (width, height, depth, channels)
  CImg<double> img(cols, rows, 1, 1);
  CImg<double> pri(cols, rows, 1, 1);
  
  // Efficiently copy R Matrix (Column-major) to CImg (Row-major storage)
  // We use the same nested loop logic to ensure spatial alignment
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      img(c, r) = im(r, c);
      pri(c, r) = priority(r, c);
    }
  }
  
  img.watershed(pri, fill_lines);
  
  // Copy back
  NumericMatrix out(rows, cols);
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      out(r, c) = img(c, r);
    }
  }
  
  return out;
}

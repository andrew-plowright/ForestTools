#include <Rcpp.h>
using namespace Rcpp;

//' Create a 0 degree GLCM
//' 
//' Used internally by glcm()
//' 
//' @param x A Numeric matrix, integer values only
//' @param n_grey Number of grey levels
//' @param d distance from reference pixel to neighbour pixel
// [[Rcpp::export]]
NumericMatrix glcm0(NumericMatrix x, int n_grey, int d){
  //add 1 extra row/column for NAs (whether or not they exist)
  NumericMatrix counts(n_grey + 1, n_grey + 1);
  
  for(int i = 0; i < x.nrow(); i++){
    for(int j = 0; j < x.ncol() - d ; j++){
      int ref_val = x(i,j);
      int nei_val = x(i, j+d);    
      counts(ref_val, nei_val) += 1;
    }
    
  }
  
  return counts;
}

//' Create a 90 degree GLCM
//' 
//' Used internally by glcm()
//' 
//' @param x A Numeric matrix, integer values only
//' @param n_grey Number of grey levels
//' @param d distance from reference pixel to neighbour pixel
// [[Rcpp::export]]
NumericMatrix glcm90(NumericMatrix x, int n_grey, int d){
  //add 1 extra row/column for NAs (whether or not they exist)
  NumericMatrix counts(n_grey + 1, n_grey + 1);
  
  for(int i = d; i < x.nrow(); i++){
    for(int j = 0; j < x.ncol(); j++){
      int ref_val = x(i,j);
      int nei_val = x(i-d, j);
      counts(ref_val, nei_val) += 1;
    }
    
  }
  
  return counts;
}

//' Create a 45 degree GLCM
//' 
//' Used internally by glcm()
//' 
//' @param x A Numeric matrix, integer values only
//' @param n_grey Number of grey levels
//' @param d distance from reference pixel to neighbour pixel
// [[Rcpp::export]]
NumericMatrix glcm45(NumericMatrix x, int n_grey, int d){
  //add 1 extra row/column for NAs (whether or not they exist)
  NumericMatrix counts(n_grey + 1, n_grey + 1);
  
  for(int i = d; i < x.nrow(); i++){
    for(int j = 0; j < x.ncol() - d; j++){
      int ref_val = x(i,j);
      int nei_val = x(i-d, j+d);
      
      //Rcout << "The ref_value is " << ref_val << std::endl;
      //Rcout << "The nei_value is " << nei_val << std::endl;
      counts(ref_val, nei_val) += 1;
      //Rcout << counts << std::endl;
    }
    
  }
  
  return counts;
}

//' Create a 135 degree GLCM
//' 
//' Used internally by glcm()
//' 
//' @param x A Numeric matrix, integer values only
//' @param n_grey Number of grey levels
//' @param d distance from reference pixel to neighbour pixel
// [[Rcpp::export]]
NumericMatrix glcm135(NumericMatrix x, int n_grey, int d){
  //add 1 extra row/column for NAs (whether or not they exist)
  NumericMatrix counts(n_grey + 1, n_grey + 1);
  
  for(int i = d; i < x.nrow(); i++){
    for(int j = d; j < x.ncol(); j++){
      int ref_val = x(i,j);
      int nei_val = x(i-d, j-d);
      
      //Rcout << "The ref_value is " << ref_val << std::endl;
      //Rcout << "The nei_value is " << nei_val << std::endl;
      counts(ref_val, nei_val) += 1;
      //Rcout << counts << std::endl;
    }
    
  }
  
  return counts;
}


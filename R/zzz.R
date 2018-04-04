
# Print messages with package is attached
.onAttach <- function(libname, pkgname) {
  packageStartupMessage("ForestTools 0.2.0 backwards compability warning: see NEWS file")
}

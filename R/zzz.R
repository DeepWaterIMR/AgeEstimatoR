.onAttach <- function(libname, pkgname) {
  options(timeout = max(6000, getOption("timeout")))
}

# Define global variables
# utils::globalVariables(c("dl_age_estimator"))

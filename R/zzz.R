# .onLoad = function (libname, pkgname) {
#   ns = topenv()
#   ns$dl_age_estimator = system.file("python", "dl_age_estimator.py", package = "AgeEstimatoR")
# }

.onAttach <- function(libname, pkgname) {
  options(timeout = max(6000, getOption("timeout")))
}

# Define global variables
# utils::globalVariables(c("dl_age_estimator"))

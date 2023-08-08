#' Perform extra actions on loading swisspalmR
#' @param libname Ensures function runs. Not used.
#' @param pkgname Ensures function runs. Not used.
#' @importFrom memoise memoise
.onLoad <- function(libname, pkgname) {
  # getSWISSpalmData_httr <<- memoise::memoise(SWISSpalm_httr)
  SWISSpalm_selenium <<- memoise::memoise(SWISSpalm_selenium)
}
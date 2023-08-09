#' Perform extra actions on loading swisspalmR
#' @param libname Ensures function runs. Not used.
#' @param pkgname Ensures function runs. Not used.
#' @importFrom memoise memoise
.onLoad <- function(libname, pkgname) {
  swissPalm <<- memoise::memoise(swissPalm)
}
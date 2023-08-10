#' Perform extra actions on loading swisspalmR
#' @param libname Ensures function runs. Not used.
#' @param pkgname Ensures function runs. Not used.
#' @keywords internal
#' @noRd
.onLoad <- function(libname, pkgname) {
  swissPalm <<- memoise::memoise(swissPalm)
}
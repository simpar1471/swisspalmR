#' Perform extra actions on loading swisspalmR
#' @param libname Ensures function runs. Not used.
#' @param pkgname Ensures function runs. Not used.
.onLoad <- function(libname, pkgname) {
  getSWISSpalmData <<- memoise::memoise(getSWISSpalmData)
}
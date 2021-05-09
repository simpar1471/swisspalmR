#' @name sendToSWISSpalm
#' @title Send to SWISSpalm
#' @description Send protein identifiers to SWISSpalm
#' @param identifiers foo1
#' @param output.type foo2
#' @param output.dir foo3
#' @return Saves SWISSpalm output in specified user-specified output directory.
#' @author Simon Parker  \email{tadeo5@hotmail.co.uk}
#' @export
sendToSWISSpalm <- function(identifiers, output.type = "vec", output.dir){
  if(missing(identifiers)) stop("You must provide protein identifiers.")
  if(missing(output.dir)) stop("You must provide an output directory.")

  message("Sending identifiers to SWISSpalm.")
  message(paste0("Retrieving ", output.type, " from SWISSpalm."))
}

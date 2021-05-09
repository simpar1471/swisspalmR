#' @name sendToSWISSpalm
#' @title Send to SWISSpalm
#' @description Send protein identifiers to SWISSpalm
#' @param identifiers Vector of protein identifiers
#' @param dataset.value Value indicating the desired dataset
#' @param species.value Value indicating the species preference
#' @param output.dir If specified, indicates the directory in which the results will be saved.
#' @return Saves SWISSpalm output in specified user-specified output directory.
#' @author Simon Parker  \email{tadeo5@hotmail.co.uk}
#' @export
sendToSWISSpalm <- function(identifiers, dataset.value = 1, species.value = 1, output.dir){
  if(missing(identifiers)) stop("You must provide protein identifiers.")

#  checkmate::checkPathForOutput(x = tempfile(pattern = file.path(output.dir, "test_file"), fileext = ".tmp"))
  message("Sending identifiers to SWISSpalm.")
  swisspalm_json <- rjson::toJSON(list(ids = identifiers,
                                       dataset = dataset.value,
                                       species = species.value,
                                       output = output.type))

  response <- httr::GET("https://www.swisspalm.org/", )

  message(paste0("Retrieving ", output.type, " from SWISSpalm."))
  swisspalm_output <- rjson::fromJSON(response$content)

  if(!missing(output.dir)){ write(swisspalm_output, file = file.path(output.dir, "swisspalm_output.txt")) }

}


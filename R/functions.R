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
sendToSWISSpalm <- function(identifiers, dataset.value = 1, species.value = 1){
  if(missing(identifiers)) stop("You must provide protein identifiers.")

  message("Sending identifiers to SWISSpalm.")
  swisspalm_list <- list(ids = identifiers,
                         dataset = dataset.value,
                         species = species.value)

  response <- httr::POST(url = "https://www.swisspalm.org/",
                         body = swisspalm_list,
                         encode = content_type("application/json"))

  message(paste0("Retrieving data from SWISSpalm."))
  swisspalm_output <- rjson::fromJSON(response$content)
  return(swisspalm_output)
  }


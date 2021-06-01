#' @name sendToSWISSpalm
#' @title Send to SWISSpalm
#' @description Send protein identifiers to SWISSpalm
#' @param identifiers Vector of protein identifiers.
#' @param dataset.value Value indicating the desired dataset.
#' @param species.value Value indicating the species preference.
#' @param output.dir If specified, indicates the directory in which the results will be saved.
#' @return Returns parsed SWISSpalm output.
#' @author Simon Parker  \email{tadeo5@hotmail.co.uk}
#' @export
sendToSWISSpalm <- function(identifiers, dataset.value = "all", species.value = 1){
  if(missing(identifiers)) stop("You must provide protein identifiers.")

  swisspalm_list <- list(free_text = as.vector(paste0(identifiers, collapse = ", ")),
                         #limit = 100,
                         dataset = dataset.value,
                         organism_id = (as.character(species.value)),
                         #load_times = 1,
                         #edit_cart = 0,
                         #render_stats = 0,
                         #use_cart = 0,
                         #format = "html"
                         )

  message("Sending identifiers to SWISSpalm.")
  swisspalm_output <- httr::POST(url = "https://www.swisspalm.org/proteins/search",
                                 #config = httr::add_headers(`Accept-Encoding` = "gzip, deflate, br",
                                                            #Connection = "keep-alive",
                                                          #  `Content-Type` = "multipart/form-data",
                                                        #    DNT = "1",
                                                        #    Host = "swisspalm.org",
                                                        #    Origin = "https://swisspalm.org",
                                                       #     Referer = "https://swisspalm.org/proteins",
                                                        #    boundary = "----WebKitFormBoundary2QgxTUXdgmYH0O1D",
                                                        #    `X-Requested-With` = "XMLHttpRequest"
                                                       #     ),
                                 body = swisspalm_list,
                                 encode = "json")

  message(paste0("Retrieving data from SWISSpalm."))
  response <- parseSWISSpalmResponse(swisspalm_output)

  return(list(swisspalm_output, response))
}

#' @name parseResponse
#' @title Parse SWISSpalm response
#' @description Parse/extract information from SWISSpalm
#' @param swiss.response Response from POST request to SWISSpalm
#' @return Returns adequately parsed SWISSpalm response.
#' @author Simon Parker  \email{tadeo5@hotmail.co.uk}
parseSWISSpalmResponse <- function(swiss.response){
  content <- swiss.response$content
  #return(rvest::html_table(rvest::read_html(rawToChar(content))))
  return(NA_character_)
}

#z <- sendToSWISSpalm(identifiers = c("P60879","P60878"))[[1]]
#print(z$request)

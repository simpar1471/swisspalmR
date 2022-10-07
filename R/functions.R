#' @name sendToSWISSpalm
#' @title Send to SWISSpalm
#' @description Send protein identifiers to SWISSpalm
#' @param identifiers Vector of protein identifiers.
#' @param dataset.value Value indicating the desired dataset.
#' @param species.value Value indicating the species preference.
#' @param output.dir If specified, indicates the directory in which the results will be saved.
#' @return Returns parsed SWISSpalm output.
#' @author Simon Parker  \email{simon.parker1471@outlook.co.uk}
#' @export
sendToSWISSpalm <- function(identifiers, dataset.value = "all", species.value = 1){
  if(missing(identifiers)) stop("You must provide protein identifiers.")

  message("Getting SWISSpalm identification data (cookie + CSRF identifier).")
  swisspalm_get_data <- httr::GET(url = "https://www.swisspalm.org/")
  swisspalm_html <- content(swisspalm_get_data, as = "text")
  CSRF_regex <- regexpr(text = swisspalm_html, pattern = '"csrf-token" content=\".*\"')
  CSRF_token <- substr(swisspalm_html,
                     start = CSRF_regex[1],
                     stop = CSRF_regex[1] + 110) |>
    substr(start = 23, stop = 23 + 87)
  swisspalm_cookie <- c('_swisspalm_session' = swisspalm_get_data$cookies$value)
  # Will need to use V8 for R
  # TODO: Look at https://cran.r-project.org/web/packages/V8/vignettes/v8_intro.html

  # Make body string using SWISSpalmXHRString function.
  body_li <- list(`free_text` = "P60879, P60878",# as.vector(paste0(identifiers, collapse = ", ")),
                  `limit` = "100",
                  `dataset` = "1", # dataset.value,
                  `organism_id` = "1", #(as.character(species.value)),
                  `load_times` = "1",
                  `edit_cart` = "0",
                  `render_stats` = "0",
                  `use_cart` = "0",
                  `format` = "html"
  )
  boundary_str <- "----WebKitFormBoundaryFORSWISSpalm"
  XHRbody <- SWISSpalmXHRString(body.li = body_li, boundary.str = boundary_str) |>
    enc2utf8()

  swisspalm_headers <- c(`Accept` = "*/*",
              `Accept-Language` = 'en-GB,en-US;q=0.9,en;q=0.8,hy;q=0.7',
              `Connection` = 'keep-alive',
              `Content-Type` = paste0('multipart/form-data; boundary=', boundary_str),
              `DNT` = '1',
              `Host` = "swisspalm.org",
              `Origin` = 'https://swisspalm.org',
              `Referer` = 'https://swisspalm.org/proteins',
              `X-CSRF-Token` = CSRF_token,
              `X-Requested-With` = 'XMLHttpRequest'
  )

  # Set headers and cookies in separate objects
  message("Sending identifiers to SWISSpalm.")
  swisspalm_post_response <- httr::POST(url = "https://www.swisspalm.org/proteins/search",
                                        httr::set_cookies(.cookies = swisspalm_cookie),
                                        httr::add_headers(.headers = swisspalm_headers),
                                        body = XHRbody,
                                        httr::verbose(data_in = T))

  message(paste0("Retrieving data from SWISSpalm."))
  response <- parseSWISSpalmResponse(swisspalm_output)

  return(list(swisspalm_output, response))
}

#' @name parseSWISSpalmResponse
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

#' @name SWISSpalmXHRString
#' @title Generate XML HTTP Request for SWISSpalm
#' @description Uses input list to generate XHR payload for SWISSpalm requests
#' @param body.li List of components to be included in the XHR.
#' @param boundary.str String used to separate form components in the XHR.
#' @return Returns string used in [LINK TO sendToSWISSpalm].
#' @author Simon Parker  \email{tadeo5@hotmail.co.uk}
SWISSpalmXHRString <- function(body.li, boundary.str) {
  line_sep <- "\r\n"
  body_start <- paste0(boundary.str, line_sep)
  body_centre <- mapply(names(body.li), body.li,
                        FUN = function(name, value) {
                          name_str <- paste0('Content-Disposition: form-data; name="', name, '"')
                          paste0(c(name_str, "", value), collapse = line_sep)
                        }) |>
    paste0(collapse = line_sep)
  body_end <- paste0(line_sep, boundary.str, "--", line_sep)
  return(paste0(body_start, body_centre, body_end))
}

z <- sendToSWISSpalm(identifiers = c("P60879","P60878"))[[1]]


stringr::str_detect(string = "_swisspalm_session=SGZTRDgrT2VsMnUyRlo4LzgzL2dtRnIzbzR3Mk8yWCt6ZURUN2I1a0lhNGhwOFc5UHFLdE9USktEd2xLY2Faa0RXU0lrbDZnVzRvOHVQVXJ5Y004bTZTTlpVMElucHR5K3NzbG4wODAvaDNWNnNFTG1tV2pqZUNPS0ppSGpyZE15cDFXSW5FTndSMVYweHh1Tzc5dnVJdHQ4RlJQRGhQMVRQSlJzWm55Wk1ITTI5QWFiMDhhRTB6YXNIdVI4RmNNQmErUUFyZXJzcHF2U0FINllVZXl1TDFDMVNSWlBIbGNBbUp3eThjY3NtNVEwSkRzdE5NM2hTZmtRcVJJWHdSbzBMbmRIbkI0Q0hYQjB4Tkhaa2JJVlVIbklYdG5sQXpvdE9tL3owK1EvQ214SGFXUE5PeFZ3N0ZDMEZCa1pobFlac1lCbWVqdGwxNkoxMWFWa2J6Q3R0QW5yM2ZZUkcwSVZNTzBSVWxQTDNNU09vaGMrdVlkU1R1STU4bTJiVWxLUnFsRGQyc0ZEYmNuRDBzZGROMS9sNkZGYVExdXJSRlBXZHhVYXN0dDRnU3FXRHE1UnQzajdyVUdGWjMvRnBxL1VkOU9yZ25MdjhHTzVOU3dYOW5Eem9IY0J6WTRhZXhaWXUyOU4zSmlzeTlyb0xjWkpPNVAvK0sySVFobGdQU1ZpRXV1RXZBM0dXOXpxbitDM1FWUDdzMlhrejZ5ZVYvMmNiRldFYTBDZlY1YUhaVXpONnU3RUNuZ2ZpYTRYQzFUODZKQVNIVXROS3BWM2xxeWI1b2lzVlZHUGJiS2VhRjVtWGdWWENIRlJiNFRvZ0UzRHNXK2haRDdOZW8wcVU1eXpOemdERTNNblJuUURIWVRlZERQZ3QxS0RCTjJGQ05KcVFKT0RJakZTQWJLVFVzbXBGalh5dU1zQ2NIdmNnWmlQcHhKK2hNcnU5NW5TMHo4T2tNN1BVQlZlKzNWYzJ0RGcwOVY1NjRzQjREMERGZUJ4cld4cmI4L1J4TzY0b2NaUndFWmJoVDhQTEw5S2JBV2RVSC9wM1lOK0VaS2ZoTllUSGxISEJ3TEY5bGpVaGpWallBWE5Oc0sxd1Y1Qjd6VEJkS0paSit2bzlNUnlXWWJMVmYyRGVJMklzQjZwWjArRnF5M0k4RUcxKy9MOGorYkdiblAyZE1JR1d5Z2NrRHFzOXBqN2hzRUFNNlZXSHpITlNyMVhQZUlFMG9MeEFYWFQwWXBVTEJqVFhsOHRmRnYvaTBCS0xEaUdGamF2YWJyQ3d3WVNwMFM3NmxxeTMwWWxHQlc0QXh0OG1yRHFwdG11YUFKVHZvTnVVdz0tLWx3QkZ0TFdPZWRQSXZDLzNwN1BMQkE9PQ%3D%3D--88c2a690b7c350966cc6192da092aa25f15a77aa",
                    pattern = "EwH")
#' @name sendToSWISSpalm
#' @title Send to SWISSpalm
#' @description Retrieve available palmitoylation data from SWISSpalm using protein identifiers
#' @param identifiers Vector of protein identifiers.
#' @param dataset.value Value indicating the desired dataset.
#' @param species.value Value indicating the species preference.
#' @return Returns parsed SWISSpalm output.
#' @author Simon Parker  \email{simon.parker1471@outlook.co.uk}
#' @export
sendToSWISSpalm <- function(identifiers, dataset.value = "all", species.value = 1){
  if(missing(identifiers)) stop("You must provide protein identifiers.")

  message("Getting SWISSpalm identification data (cookie + CSRF identifier).")
  swisspalm_get_data <- httr::GET(url = "https://www.swisspalm.org/")
  swisspalm_html <- httr::content(swisspalm_get_data, as = "text")
  CSRF_regex <- regexpr(text = swisspalm_html, pattern = '"csrf-token" content=\".*\"')
  CSRF_token <- substr(swisspalm_html,
                     start = CSRF_regex[1],
                     stop = CSRF_regex[1] + 110) |>
    substr(start = 23, stop = 23 + 87)
  swisspalm_cookie <- c('_swisspalm_session' = swisspalm_get_data$cookies$value)
  # Will need to use V8 for R
  # TODO: Make this use memoise (https://memoise.r-lib.org/) for caching function calls when possible

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
#' @author Simon Parker  \email{simon.parker1471@outlook.com}
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
#' @author Simon Parker  \email{simon.parker1471@outlook.com}
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

# https://stackoverflow.com/questions/52084767/xhr-scrape-request-url-not-changing
# copy cURL as bash; use curlconverter::straighten() and curlconverter::
swisspalm_response <- httr::VERB(
  verb = "GET", url = "https://swisspalm.org/proteins/search",
  httr::add_headers(
    Accept = "*/*",
    `Accept-Language` = "en-GB,en-US;q=0.9,en;q=0.8,hy;q=0.7",
    Connection = "keep-alive",
    DNT = "1",
    Origin = "https://swisspalm.org",
    Referer = "https://swisspalm.org/proteins",
    `Sec-Fetch-Dest` = "empty",
    `Sec-Fetch-Mode` = "cors",
    `Sec-Fetch-Site` = "same-origin",
    `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
    `X-CSRF-Token` = "YBKpXBINYHJy/Y9t/JNEgoczsVys4KwN4r4bjXvpNQatQ+WnEQ20e35c+DIs5scEPcLNGsBRXRmLXxLIXTu5YQ==",
    `X-Requested-With` = "XMLHttpRequest",
    `sec-ch-ua` = "\"Google Chrome\";v=107\", \"Chromium\";v=\"107\", \"Not=A?Brand\";v=\"24",
    `sec-ch-ua-mobile` = "?0",
    `sec-ch-ua-platform` = "\"Windows\"",
    `sec-gpc` = "1"
  ), httr::set_cookies(`_swisspalm_session` = "cmUzL2lnVTJPeXk2VExsQjF6ZTRXT1Q3Wmdpd2QvYy9aVUR2cCtyNk5YMllPa1dGeDdiK0dmREJvazZQUzFqTWpyVVlpRlp4UkN0WjltbGZqUi9mVmdQcUFCVTk5RHplT1FGZXFDNjlaMVN4TW9EaFpvUkhFKzZ6UnJjbkdPOElvYVJGYkRFVzdxbTFnQ0VnQVU1R2g4NlkrUnNLeFJUcW9VeXNhSVplek9TN1N1cysxL2ZlQVUyb0l6eWM2ak9kbEd4WVJSK011NUN5SERveWF5SFgvcWI5c0FEOHNCeFpRbDlCRzJDcTJFSUJYTFFaSUIxZXJVSHpCQmxaRE1obzlJRUdURGdWMzE2aGtUV0NUdElIY2s5amJVc0duQnlUYlBVN3FFN0I2cUtVT3ZpSGRuUXZBSnE4SEZCL3VOa2tFZHVVOXh2dUZrazVnRVk5aDM0QTRmZTkyeHpzQXN0ZG1yYVJjZ0JuWnFySFcwd0tIeXhaMmpKVE5rN2E4RU9JY2g4LzgvSk0wZmkxY2lzWW1mWS9STDNYVXZzN2ZHaklab3k3ck9MVDR4T3grNXZwKzF1a2EvVHNGWFNqNm1rSmI1RjhTNWtrSXY5MStHUytGRTgrR2dncEpMdFVNTDZhMGxhZ3hZdk5oNUk0NlBRSVhydG1TaU1kMENHc2Ziem5TSlRLWVZ5Zk5TL1V3WFBTdTJPdTVTWDc4SU9ONlRRbjZPUmp4MjJZQlVJZ2NGUVNZOUNXa3hYajhQdTBPREI3dDJqaXpwdzhpRFNTSE5rY29PR2pVeHB4bUs4STJreEYyNWFXZjBLd3p5N1h6dGswY0VjMUNLZkw3WWdXVVozM3FVVVRyM0ErWmQ2K1NPcGJLSVEwazRTMTE5MEsyVTVldW9yQld0aWllVWFJc0RRK1V6TldEbW9uQklzL1phKzhqL1hHUlJKMk5UaDNwUE9jTzIyeWhrR0V4Rms0WWpPQng1SmtYUzloOXZRZ0d1dDc2am1yU2c0aGZ6amlmNWl2UEZ2cm5rTTdYSno1Wi9nY3R3Y0dud0g5OEpXNnAzSk9Kbjc5NE1EbTV0QjJzRDNJcm5qZXgvejh5azcyb1ZzNTAwT0FOS0NvU2ZiNkhVVU10a2s5T3BidTFNWElCZXJwSjZXL0NoM0RzbjhyYnlzVVZpa3JuNXdCYWdSYmQzcXFCU1padGhLYmFZcWZ4b1pRdU03MG03akpuV2JNZXd6UmhwZUJnOTYvOHVUdGo1QThrM0hJdTlRQVdXRm5heFJITEJZNU1VTWpPc1h3clgzYTdSY09zWnRjTzZtU2VFVGxobyt4cDdYckFOOD0tLXZnT0hFeGlUa0Jnb2U1ZkVvL05laHc9PQ%3D%3D--68310c371a14c5a2a9e13deba5498fe42e69de41"),
  encode = "multipart"
)



#' Get palmitoylation data from SWISSpalm using httr
#'
#' @param protein.identifiers Character vector with protein identifiers. Should be an ID type supported by SWISSpalm (https://swisspalm.org/file_formats).
#' @param download_dir Directory in which temporary files will be downloaded. Defaults to R temporary directory.
#' @param dataset Which dataset should SWISSpalm use? See valid values in \[swisspalm::dataset_values]. Default = `"all"` (all datasets).
#' @param species Which species should SWISSpalm search for? See \[swisspalm::species_values] for valid values. Default = 0 (all species)
#' @param verbose If TRUE, send status messages to the console.
#' @return Data frame containing palmitoylation data for proteins in protein.identifiers.
SWISSpalm_httr <- function(protein.identifiers, download_dir = tempdir(), dataset = "all", species = NULL) {
  if (!dataset %in% swisspalmR::dataset_values) {
    stop("dataset.value is not in swisspalmR::dataset_values")
  }
  species <- if (is.null(species)) "" else as.character(species)
  if (!species %in% swisspalmR::species_values) {
    stop("species.value is not in swisspalmR::species_values")
  }

  res_GET1 <- httr::GET(
    url = "https://swisspalm.org/proteins/"
  )

  if (httr::http_status(res_GET1)$category != "Success") {
    stop(paste0("Initial GET request not successful. Status code was '",
                httr::http_status(res_GET1)$message), "'.")
  }
  cookies <- httr::cookies(res_GET1)
  cookies <- c(`_swisspalm_session` = cookies$value)

  webkit_boundary <- paste0("-----------------------------",
                            stringi::stri_rand_strings(n = 1, length = 30,
                                              pattern = "[0-9]"))

  xhr <- purrr::map2_chr(
    .x = c("free_text", "limit", "dataset", "organism_id", "load_times",
           "edit_cart", "render_stats", "use_cart", "format"),
    .y = list(paste0(protein.identifiers, collapse = ", "),
              "100", dataset, species, "1", "", "0", "0", "html"),
    .f = ~ paste0(
      webkit_boundary, "\n",
      r"(Content-Disposition: form-data; name=")", .x, "\"\n",
      "\n",
      .y, "\n"
    )
  ) |>
    paste0(collapse = "") |>
    paste0(webkit_boundary, "--")

  xhr_li <- list(paste0(protein.identifiers, collapse = ", "),
                 "100", dataset, species, "1", "", "0", "0", "html")
  xhr_li <- xhr_li |>
    purrr::set_names(
      c("free_text", "limit", "dataset", "organism_id", "load_times",
        "edit_cart", "render_stats", "use_cart", "format"))

  headers <- c(
    `Accept` = "*/*",
    # `Accept-Encoding` = "gzip, deflate, br",
    # `Accept-Language` = "en-GB,en;q=0.5",
    # `Connection` = "keep-alive",
    `Content-Length` = paste0("multipart/form-data; boundary=", webkit_boundary),
    `Content-Type` = paste0("multipart/form-data; boundary=", webkit_boundary),
    `DNT` = "1",
    `Host` = "swisspalm.org",
    `Origin` = "https://swisspalm.org",
    `Referer` = "https://swisspalm.org/proteins",
    # `Sec-Fetch-Dest` = "empty",
    # `Sec-Fetch-Mode` = "cors",
    # `Sec-Fetch-Site` = "same-origin",
    # `Sec-Fetch-User` = "?1",
    # `Upgrade-Insecure-Requests` = "1",
    `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0",
    `X-Requested-With` = "XMLHttpRequest"
  )

  res_POST <- httr::POST(url = "https://www.swisspalm.org/proteins/search",
                         httr::add_headers(.headers = headers),
                         httr::set_cookies(.cookies = cookies),
                         body = xhr)

  if (httr::http_status(res_POST)$category != "Success") {
    stop(paste0("POST not successful. Status code was '",
                httr::http_status(res_POST)$message), "'.")
  }
}

SWISSpalm_httr(protein.identifiers = c("P05067", "O00161", "P04899"),
               dataset = "all")
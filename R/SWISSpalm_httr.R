#' Get palmitoylation data from SWISSpalm using httr
#'
#' @param protein.identifiers Character vector with protein identifiers. Should be an ID type supported by SWISSpalm (https://swisspalm.org/file_formats).
#' @param download_dir Directory in which temporary files will be downloaded. Defaults to R temporary directory.
#' @param dataset Which dataset should SWISSpalm use? See valid values in \[swisspalm::dataset_values]. Default = `"all"` (all datasets).
#' @param species Which species should SWISSpalm search for? See \[swisspalm::species_values] for valid values. Default = 0 (all species)
#' @param verbose If TRUE, send status messages to the console.
#' @return Data frame containing palmitoylation data for proteins in protein.identifiers.
SWISSpalm_httr <- function(protein.identifiers, download_dir = tempdir(), dataset = "all", species = NULL, verbose = F) {
  if (!dataset %in% swisspalmR::dataset_values) {
    stop("dataset.value is not in swisspalmR::dataset_values")
  }
  species <- if (is.null(species)) "" else as.character(species)
  if (!species %in% swisspalmR::species_values) {
    stop("species.value is not in swisspalmR::species_values")
  }

  res_GET1 <- httr::GET(
    url = "https://swisspalm.org/proteins/refresh_form?first_load=true"
  )
  if (httr::http_status(res_GET1)$category != "Success") {
    stop(paste0("Initial GET request not successful. Status code was '",
                httr::http_status(res_GET1)$message), "'.")
  }
  cookies <- httr::cookies(res_GET1)
  cookies <- c(`_swisspalm_session` = "T0JMaVZya1NoYkdoQ0g0Q2VLM1A0Y2FJQUdPL0g1YmdzOVNUZ3c0aXA0UEg5MnorTnliK0JYQ1lJdVVTemVEYXEwTmwzaUJnaU05bzgvM2xsa0RoOVpTUXBaZjQrYkoyaGFGb1k3cExCZVQvSVN6cStzdVc4eEhBZWoyQ2tJSEFoSnhodUNkS3ZJbkwzZUJFWG8rOWpacm5FVTI0TllMY0grOXZsL3VkSEt3cmxrcmtCRVFIVCtjdm9vamJJT2Z1Y1lFcDRjakh0cDlFenlwZ1dudGZIZHFwM016Ui9lUHk1YnNMZGdsU09PUmlFditmblVEaUlMTmF3SDYzTEJ4bk5tY29keW13ZkNOQktLQ1VneDF6UGRqZWtDeUZhdXFkR2RKYnhxakN5WDZMUTI3SlJRQzJaNjFMWHgwWlhDYlk3bGVMdmJoMU43K2J2TEcyRUdvZXBNbVpqaTRydlR6UnR5RzF6Uk5ucWl2RTM0d0VHT0t4RTY2ek5vTUpMMXZoNU9Nb2RaYWtlbXJWRitLb0tNS29NZnZaYkxQKzluTGpyS2ptTWdCYzdaNzdPRHdNbGx4M3BNek1BUVZYSFFFQlJoOExYNE4va1J0MzVXRkFaNG92NGdtOVZPKzZmSWRWZzZVM2M0akJhTXExVVprbkJzMWN5cGVSV1BLcmFaMXlwWGcyV0RhWkRPcndpMGtMRWkyODdjNmxlUkNHTkNGMVZqNUhRbS9LZGFkYVM4aHJ4SjEvZFJwVERhYnNpTUZFOXN1enRPd3E2ajhhZVc0THJCRkI1MWJhRlBtTXE5WkNZbzdUNlg1QTQrQVdMNlIrVHVHQXg0NkM3YzFGTDNlc1hsVm9sOVZXV0syU3FodXpFSzU0ZU01aW9DZWsxNjhjOUVsUTZ3QnlCM1lsQkE4Nis0bEJ5blJYNURWQ0YzcnVQN0lNRm13ZU1ZMHhXbUtZTmM0Uy9BOHJRY3ZCUnhLYmw0VFhNajNTMVpsMnJNZ1JydVJIamxxSytjNlVIMFM2bWgxbkExakhtbmhzd3BXYzFLWnM0U1REZWxjekJkeFNPa3RYaGIxdGFpWkFIVDR2SlpIZlQzWmFFN1Fxd0haYTZoN2FaSEFjSmdlY1cvTkJDa3RtMG4wQ2EzTE1rOWpsMG1XSENPc2hvUGZGR2RsREpPdldLcjc5Z0hjKzBHUDE4TkFFdmJ4djcrNkpsUTB6eFN6MkgxWDJHR2JrU2RaWHAvL2F0THhZYzdwY2U0RVk5eHNIaDhpUERFV29WWFA3RGhTbHo2bm5CQURJdjVCQWNyWGxOb1hyb2FCYkJQZWttb3o3b25Mc0JrRXduMGlUdXJrWjh4TGZuYzdqUHFPWS0tdUtpV293akNObnhyeFZGRTNBQnZQUT09--2ffbfb7ac8b90efa75cff7d669c95bc9cbbb95ff")
  #cookies$value)
  webkit_16char <- stringi::stri_rand_strings(1, length = 16)

  headers <- c(
    `Accept` = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    `Accept-Encoding` = "gzip, deflate, br",
    `Accept-Language` = "en-GB,en-US;q=0.9,en;q=0.8,hy;q=0.7",
    `Cache-Control` = "max-age=0",
    `Connection` = "keep-alive",
    # `Content-Length` = "1259",
    # `Content-Type` = paste0("multipart/form-data; boundary=----WebKitFormBoundary", webkit_16char),
    `Content-Type` = "multipart/form-data; boundary=----WebKitFormBoundaryrrX3OqgZXpPnjDDB",
    `DNT` = "1",
    `Host` = "swisspalm.org",
    `Origin` = "https://swisspalm.org",
    `Referer` = "https://swisspalm.org/proteins",
    `Sec-Fetch-Dest` = "document",
    `Sec-Fetch-Mode` = "navigate",
    `Sec-Fetch-Site` = "same-origin",
    `Sec-Fetch-User` = "?1",
    `Upgrade-Insecure-Requests` = "1",
    `User-Agent` = "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36",
    `sec-ch-ua` = "Chromium;v=112, Google",
    `sec-ch-ua-mobile` = "?1",
    `sec-ch-ua-platform` = "Android",
    `sec-gpc` = "1"
  )
  # webkit_boundary_xhr <- paste0("------WebKitFormBoundary", webkit_16char)
  # data <- paste0(
  #   webkit_boundary_xhr, "\n",
  #   "Content-Disposition: form-data; name=\"free_text\"", "\n\n",
  #   paste0(protein.identifiers, collapse = ", "), "\n",
  #
  #   webkit_boundary_xhr, "\n",
  #   "Content-Disposition: form-data; name=\"limit\"", "\n\n",
  #   "100","\n",
  #   webkit_boundary_xhr, "\n",
  #   "Content-Disposition: form-data; name=\"dataset\"", "\n\n",
  #   dataset, "\n",
  #
  #   webkit_boundary_xhr, "\n",
  #   "Content-Disposition: form-data; name=\"organism_id\"", "\n\n",
  #   species, "\n",
  #
  #   webkit_boundary_xhr, "\n",
  #   "Content-Disposition: form-data; name=\"load_times\"", "\n\n",
  #   "1", "\n",
  #
  #   webkit_boundary_xhr,"\n",
  #   "Content-Disposition: form-data; name=\"edit_cart\"", "\n\n",
  #   "", "\n",
  #
  #   webkit_boundary_xhr, "\n",
  #   "Content-Disposition: form-data; name=\"render_stats\"", "\n\n",
  #   "0", "\n",
  #
  #   webkit_boundary_xhr, "\n",
  #   "Content-Disposition: form-data; name=\"format\"", "\n\n",
  #   "text","\n",
  #   webkit_boundary_xhr, "--"
  # )
  data <- readLines(con = "R/temp.txt")
  res_POST <- httr::POST(url = "https://swisspalm.org/proteins/search",
                         httr::add_headers(.headers = headers),
                         httr::set_cookies(.cookies = cookies),
                         body = data)

  if (httr::http_status(res_POST)$category != "Success") {
    stop(paste0("POST not successful. Status code was '",
                httr::http_status(res_POST)$message), "'.")
  }
}

SWISSpalm_httr(protein.identifiers = c("P05067", "O00161", "P04899"),
               dataset = "all")
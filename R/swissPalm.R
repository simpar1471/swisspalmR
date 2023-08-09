swissPalm_tbl <- swissPalm(protein_id = c("P05067", "O00161", "P04899"), dataset = "all")

#' Get palmitoylation data from the swissPalm database
#'
#' @param protein_id Character vector with protein identifiers. Should be an ID type supported by SWISSpalm (https://swisspalm.org/file_formats).
#' @param download_dir Directory in which temporary files will be downloaded. Default = R `tempdir()` command.
#' @param dataset Which dataset should SWISSpalm use? See valid values in \[swisspalm::dataset_values]. Default = `"all"` (all datasets).
#' @param species Which species should SWISSpalm search for? See \[swisspalm::species_values] for valid values. Default = `0` (all species).
#' @param verbose If TRUE, send status messages to the console.
#' @importFrom httr2 resp_header
#' @return Data frame containing palmitoylation data for proteins in protein.identifiers.
#' @export
swissPalm <- function(protein_id, download_dir = tempdir(), dataset = "all", species = NULL) {
  swissPalm_cookie <- function(resp) {
    cookie <- resp |>
      httr2::resp_header(header = "Set-Cookie") |>
      strsplit(split = ";")
    cookie[[1]][1]
  }
  csrf_token <- function(resp_html, form_id) {
    form_str <- resp_html[stringr::str_detect(resp_html, pattern = form_id)]
    form_str <- form_str |>
      stringr::str_extract(pattern = "\"authenticity_token\" value=\".*==\"") |>
      stringr::str_extract(pattern = "value=\".*==\"") |>
      stringr::str_remove(pattern = "value=\"") |>
      stringr::str_remove_all(pattern = "\"")
  }

  user <- "swisspalmR package (IN DEVELOPMENT)"
  GET_req <- "https://swisspalm.org/proteins/refresh_form?first_load=true" |>
    httr2::request() |>
    httr2::req_user_agent(string = user)
  GET_resp <- httr2::req_perform(GET_req)

  GET_html <- httr2::resp_body_string(GET_resp) |>
    strsplit(split = "\n") |>
    unlist()
  # TODO: Add checks for dataset and species
  GET_csrf_token_search <- csrf_token(GET_html, form_id = "search_form")

  GET_cookie <- swissPalm_cookie(GET_resp)
  POST_cookie <- GET_cookie

  headers <- list(
    `Accept` = "*/*",
    `Accept-Encoding` = "gzip, deflate, br",
    `Accept-Language` = "en-GB,en-US;q=0.9,en;q=0.8,hy;q=0.7",
    `Connection` = "keep-alive",
    `Cookie` = POST_cookie,
    `DNT` = "1",
    `Origin` = "https://swisspalm.org",
    `Referer` = "https://swisspalm.org/proteins",
    `Sec-Fetch-Dest` = "empty",
    `Sec-Fetch-Mode` = "cors",
    `Sec-Fetch-Site` = "same-origin",
    `sec-ch-ua` ="\"Not/A)Brand\";v=\"99\", \"Google Chrome\";v=\"115\", \"Chromium\";v=\"115\"",
    `sec-ch-ua-mobile`="?1",
    `sec-ch-ua-platform`="\"Android\"",
    `sec-gpc`="1",
    `X-CSRF-Token` = GET_csrf_token_search,
    `X-Requested-With` = "XMLHttpRequest"
  )

  xhr_li <- list(free_text = paste0(protein_id, collapse = ", "),
                 limit = "100",
                 dataset = "all",
                 organism_id = "",
                 load_times = "1",
                 edit_cart = "",
                 render_stats = "0",
                 use_cart = "0",
                 format = "html")
  POST_req <- httr2::request(base_url = "https://swisspalm.org/proteins/search") |>
    httr2::req_headers(!!!headers) |>
    httr2::req_user_agent(string = user) |>
    httr2::req_body_multipart(!!!xhr_li)
  POST_resp <- httr2::req_perform(req = POST_req)
  POST_html <- httr2::resp_body_string(POST_resp)

  rvest::read_html(POST_html) |>
    rvest::html_table(fill = TRUE) |>
    as.data.frame() |>
    dplyr::select(!Var.1) |>
    dplyr::rename_with(.fn = \(x) stringr::str_replace(x, "\\.", "_")) |>
    dplyr::rename(`DHHC-PATs_and_APTs` = `DHHC_PATs...APTs`)

  # TODO: Attempt to download file with download_form csrf token--> inspect with
  # TODO: rvest's form extraction functions
  # GET_csrf_token_download <- csrf_token(GET_html, form_id = "download_form")
}

  # refer_url <- paste0("https://swisspalm.org/proteins?free_text=",
  #                     paste(protein_id, collapse = ",%20"))
  # sp_session <- rvest::session(url = "https://swisspalm.org/") |>
  #   rvest::session_jump_to(url = "https://swisspalm.org/proteins/refresh_form?first_load=true")
  # sp_content1 <- httr::content(x = sp_session$response, as = "text")
  # sp_content1 <- rvest::read_html(x = sp_session, as = "text")
  # sp_search <- rvest::html_form(sp_session)[[2]]
  #
  #
  # valid_datasets <- unname(sp_search$fields$dataset$options)
  # valid_species <- unname(sp_search$fields$organism_id$options)
  # dataset_default <- "all"
  # species_default <- ""
  # if (is_invalid_param(dataset, valid_datasets, default = dataset_default)) {
  #   dataset <- "all"
  # }
  # species <- if (is.null(species)) species_default else species
  # if (is_invalid_param(species, valid_species, default = species_default)) {
  #   species <- ""
  # }
  # rm(valid_datasets, valid_species, dataset_default, species_default)
  #
  # # Make new search form with dataset, species, and protein values
  # sp_search_new <- sp_search
  # sp_search_new$fields$dataset$value <- dataset
  # sp_search_new$fields$organism_id$value <- species
  # sp_search_new$fields$free_text$value <- paste(protein_id, collapse = ", ")
  # post_results <- rvest::session_submit(sp_session, sp_search_new)
  # post_results2 <- httr::content(x = post_results$response, as = "text")
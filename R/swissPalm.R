#' Retrieve palmitoylation data from the swissPalm database
#'
#' @param protein_id Character vector with protein identifiers. Should be an ID
#' type supported by SwissPalm (UniProt AC, UniProt secondary AC, UniProt ID,
#' UniProt gene name, Ensembl protein, Ensembl gene, Refseq protein ID, IPI ID,
#' UniGene ID, PomBase ID, MGI ID, RGD ID, TAIR protein ID, EuPathDb ID; from
#' the [SwissPalm website](https://swisspalm.org/file_formats)).
#' @param dataset Which dataset to use in swissPalm. Will be set to `"all"` if
#' not a value from `swisspalm::datasets`. Default = `"all"` (all datasets).
#' @param species Which dataset to use in swissPalm. Will be set to `"all"` if
#' not a value from `swisspalm::species`. Default = `"all"` (all datasets).
#' @return Data frame with palmitoylation data for proteins in `protein_id`,
#' and notes for proteins not found in SwissPalm.
#' @examples
#' swisspalmR::swissPalm(protein_id = c("P05067", "O00161", "P04899", "P98019"))
#' 
#' # Use 'species' parameter to limit your results to those for a species of 
#' # interest
#' swisspalmR::swissPalm(
#'   protein_id = c("P05067", "O00161", "P04899", "P98019"),
#'   species = swisspalmR::species["Mallard duck"]
#'   )
#' @export
swissPalm <- function(protein_id, dataset = "all", species = NULL) {
  if (length(protein_id) == 0) {
    cli::cli_abort("{.var protein_id} must have length >= 1")
  }
  species <- if (is.null(species)) "" else species
  check_species_dataset(species, dataset)

  user <- "swisspalmR package (https://simpar1471.github.io/swisspalmR/)"
  GET_req <- "https://swisspalm.org/proteins/refresh_form?first_load=true" |>
    httr2::request() |>
    httr2::req_user_agent(string = user)
  GET_resp <- httr2::req_perform(GET_req)
  GET_html <- httr2::resp_body_string(GET_resp) |>
    strsplit(split = "\n") |>
    unlist()

  GET_csrf_token_search <- csrf_token(GET_html, form_id = "search_form")
  GET_resp_cookie <- swissPalm_cookie(GET_resp)
  POST_req_cookie <- GET_resp_cookie

  headers <- list(
    `Accept` = "*/*",
    `Accept-Encoding` = "gzip, deflate, br",
    `Accept-Language` = "en-GB,en-US;q=0.9,en;q=0.8,hy;q=0.7",
    `Connection` = "keep-alive",
    `Cookie` = POST_req_cookie,
    `DNT` = "1",
    `Origin` = "https://swisspalm.org",
    `Referer` = "https://swisspalm.org/proteins?batch_search=1",
    `X-CSRF-Token` = GET_csrf_token_search,
    `X-Requested-With` = "XMLHttpRequest"
  )

  path_upload <- tempfile(pattern = "swissPalm-", fileext = ".txt")
  writeLines(con = path_upload,
             paste(protein_id, collapse = "\n"))
  on.exit(expr = try(unlink(path_upload)), add = TRUE)

  xhr_li <- list(file = curl::form_file(path_upload),
                 free_text = "",
                 limit = "100",
                 dataset = as.character(dataset),
                 organism_id = as.character(species),
                 load_times = "1",
                 edit_cart = "",
                 render_stats = "0",
                 use_cart = "0",
                 format = "html")

  POST_req <- httr2::request("https://swisspalm.org/proteins/search") |>
    httr2::req_headers(!!!headers) |>
    httr2::req_user_agent(string = user) |>
    httr2::req_body_multipart(!!!xhr_li)

  POST_resp <- httr2::req_perform(POST_req)
  POST_html <- httr2::resp_body_string(POST_resp) |>
    rvest::read_html()

  table <- rvest::html_table(POST_html, fill = TRUE)[[1]]
  not_found <- extract_not_found(POST_html)
  if (length(table) != 0) {
    swissPalm_table <- table |>
      as.data.frame() |>
      dplyr::select(!(`UniProt status` | 1)) |>
      dplyr::mutate(Found = "found", .after = `Query identifier`)
    if (nrow(not_found) == 0) {
      return(swissPalm_table)
    } else {
      return(suppressMessages(dplyr::full_join(swissPalm_table, not_found)))
    }
  } else {
    return(not_found)
  }
}
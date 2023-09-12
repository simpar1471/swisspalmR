#' Retrieve palmitoylation data from the swissPalm database
#'
#' @param query_id Character vector with protein identifiers. Should be an ID
#' type supported by SwissPalm (UniProt AC, UniProt secondary AC, UniProt ID,
#' UniProt gene name, Ensembl protein, Ensembl gene, Refseq protein ID, IPI ID,
#' UniGene ID, PomBase ID, MGI ID, RGD ID, TAIR protein ID, EuPathDb ID; from
#' the [SwissPalm website](https://swisspalm.org/file_formats)).
#' @param dataset Which dataset to use in swissPalm. Will be set to `"all"` if
#' not a value from `swisspalm::datasets`. Default = `"all"` (all datasets).
#' @param species Which species to use in swissPalm. Will be set to `""` if
#' not a value from `swisspalm::species`. Default = `""` (all species).
#' @return Data frame with palmitoylation data for proteins in `protein_id`,
#' and notes for why any elements in `protein_id` were not found in SwissPalm.
#' @examples
#' \donttest{
#' swisspalmR::swissPalm(query_id = c("P05067", "O00161", "P04899", "P98019"))
#' }
#'
#' # Use 'species' parameter to limit your results to those for a species of 
#' # interest
#' \donttest{
#' swisspalmR::swissPalm(
#'   query_id = c("P05067", "O00161", "P04899", "P98019"),
#'   species = swisspalmR::species["Mallard duck"]
#'   )
#' }
#' @export
swissPalm <- function(query_id, dataset = "all", species = "") {
  if (length(query_id) == 0) {
    cli::cli_abort(message = "{.var query_id} must have length >= 1")
  }
  if (!is.character(query_id)) {
    cli::cli_abort(message = "{.var query_id} must be a character vector")
  }
  # This function will reset species/dataset if not valid
  check_species_dataset(species, dataset)

  user <- "swisspalmR package (https://simpar1471.github.io/swisspalmR/)"
  GET_req <- swisspalm_GET_req(user)
  GET_resp <- httr2::req_perform(GET_req)
  GET_html <- httr2::resp_body_string(GET_resp) |>
    strsplit(split = "\n") |>
    unlist()

  GET_csrf_token_search <- csrf_token(GET_html, form_id = "search_form")
  GET_resp_cookie <- swissPalm_cookie(GET_resp)
  POST_req_cookie <- GET_resp_cookie

  headers_html <- list(
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

  # Save protein IDs to temporary file which will be uploaded to SwissPalm
  path_upload <- tempfile(pattern = "swissPalm-", fileext = ".txt")
  writeLines(con = path_upload,
             paste(query_id, collapse = "\n"))
  on.exit(expr = try(unlink(path_upload)), add = TRUE)

  xhr_html <- list(file = curl::form_file(path_upload),
                   free_text = "",
                   limit = "100",
                   dataset = as.character(dataset),
                   organism_id = as.character(species),
                   load_times = "1",
                   edit_cart = "",
                   render_stats = "0",
                   use_cart = "0",
                   format = "html")

  # Request HTML webpage for given proteins - necessary to determine which
  # proteins are not found in the request
  POST_req_html <- swisspalm_POST_req(headers_html, xhr_html, user)

  POST_resp <- httr2::req_perform(POST_req_html)
  POST_html <- httr2::resp_body_string(POST_resp) |>
    rvest::read_html()
  swissPalm_not_found <- extract_not_found(POST_html)


  # Request palmitoylation information as text (i.e. same as text download on
  # website). This requires CSRF token to be provided in XHR rather than in
  # headers, so swaps occur now.
  headers_txt <- headers_html[names(headers_html) != "X-CSRF-Token"]
  headers_txt[["Cookie"]] <- swissPalm_cookie(POST_resp)

  xhr_li_txt <- xhr_html
  xhr_li_txt[["format"]] <- "text"
  xhr_li_txt[["authenticity_token"]] <- headers_html[["X-CSRF-Token"]]

  # POST request for txt download
  POST_req_txt <- swisspalm_POST_req(headers_txt, xhr_li_txt, user)
  POST_resp_txt <- httr2::req_perform(POST_req_txt)
  POST_resp_str <- httr2::resp_body_string(POST_resp_txt) |>
    gsub(pattern = "Yes", replacement = "TRUE") |>
    gsub(pattern = "No", replacement = "FALSE")

  suppressWarnings( # Otherwise no results found will throw warning
    swissPalm_table <- utils::read.table(
      text = POST_resp_str, sep = "\t", header = TRUE,
      col.names = swissPalm_table_colnames()
    ) |>
      convert_swissPalm_table_listcols()
  )
  if (nrow(swissPalm_table) >= 1) {
    swissPalm_table$Found_in_SwissPalm <- found_as_factor(x = "found")
  }

  if (is.null(swissPalm_not_found)) {
    return(swissPalm_table) # Every query ID was found
  } else if (nrow(swissPalm_not_found) == length(query_id)) {
    return(swissPalm_not_found) # Every query ID was not found
  } else {
    rbind(swissPalm_table, swissPalm_not_found) # Some found, some not
  }
}
#' @keywords internal
check_species_dataset <- function(species, dataset) {
  # Refactor? Seems off to have reset alert from cli package not in same
  # function that does the reset itself
  dataset_default <- "all"
  species_default <- ""
  if (is_invalid_param(dataset, swisspalmR::datasets, default = dataset_default)) {
    assign(x = deparse(substitute(dataset)),
           value = dataset_default, envir = parent.frame())
  }
  if (is_invalid_param(species, swisspalmR::species, default = species_default)) {
    assign(x = deparse(substitute(species)),
           value = species_default, envir = parent.frame())
  }
}

#' @keywords internal
is_invalid_param <- function(param, valid_values, default) {
  if (!param %in% valid_values) {
    param_name <- deparse(substitute(param))
    valid_values_name <- deparse(substitute(valid_values))
    sp_name <- if (param_name == "dataset") "datasets" else "species"
    cli::cli_warn(
      c(paste0("\"{param}\" is not a valid {.var {param_name}} value. ",
               "Setting \"{param}\" to default: {.var {default}}."),
        "i" = paste0("Valid {.var {param_name}} values can be found in ",
                     "{.var swisspalmR::{sp_name}}.")))
    TRUE
  } else FALSE
}

#' @keywords internal
swissPalm_cookie <- function(resp) {
  cookie <- resp |>
    httr2::resp_header(header = "Set-Cookie") |>
    strsplit(split = ";")
  cookie[[1]][1]
}

#' @keywords internal
csrf_token <- function(resp_html, form_id) {
  form_str <- resp_html[stringr::str_detect(resp_html, pattern = form_id)]
  form_str <- form_str |>
    stringr::str_extract(pattern = "\"authenticity_token\" value=\".*==\"") |>
    stringr::str_extract(pattern = "value=\".*==\"") |>
    stringr::str_remove(pattern = "value=\"") |>
    stringr::str_remove_all(pattern = "\"")
}

#' @keywords internal
extract_not_found <- function(POST_html) {
  # Get which proteins weren't found in the search
  POST_span_elems <- rvest::html_elements(POST_html, css = "span")
  POST_span_elems_id <- rvest::html_attr(POST_span_elems, name = "id")
  POST_span_elems <- rvest::html_text2(POST_span_elems)
  str_not_found_in_db <- "list_not_found"
  str_not_found_at_all <- "list_not_found_at_all"

  purrr::map_dfr(
    .x = list(str_not_found_in_db, str_not_found_at_all),
    .f = \(x) {
      proteins <- POST_span_elems[which(POST_span_elems_id == x)] |>
        strsplit(split = ", ") |>
        unlist() |>
        stringr::str_remove_all(pattern = "\n")
      found <- ifelse(x == "list_not_found",
                      yes = "not found in database",
                      no = "not found at all")
      if (!length(proteins) == 0) {
        data.frame(`Query identifier` = proteins,
                   `Found` = found)
      } else invisible()
    }
  )
}
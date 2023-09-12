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

#' Construct an HTTP GET request for SwissPalm
#' @param user User agent for the HTTP request.
#' @keywords internal
swisspalm_GET_req <- function(user) {
  "https://swisspalm.org/proteins/refresh_form?first_load=true" |>
    httr2::request() |>
    httr2::req_user_agent(string = user) |>
    httr2::req_retry(max_tries = 5,
                     is_transient = ~ httr2::resp_status(.x) %in% 500)
}

#' Construct an HTTP POST request for SwissPalm
#' @param headers A named list of headers and their values for the POST request.
#' @param xhr A list of XHR components and their values for the POST request.
#' @param user User agent for the HTTP request.
#' @keywords internal
swisspalm_POST_req <- function(headers, xhr, user) {
  httr2::request(base_url = "https://swisspalm.org/proteins/search") |>
    httr2::req_headers(!!!headers) |>
    httr2::req_user_agent(string = user) |>
    httr2::req_body_multipart(!!!xhr) |>
    httr2::req_retry(max_tries = 5,
                     is_transient = ~ httr2::resp_status(.x) %in% 500)
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
found_as_factor <- function(x) {
  factor(x, levels = c("found", "not found in database", "not found at all"))
}

#' @keywords internal
extract_not_found <- function(POST_html) {
  # Get which proteins weren't found in the search
  POST_span_elems <- rvest::html_elements(POST_html, css = "span")
  POST_span_elems_id <- rvest::html_attr(POST_span_elems, name = "id")
  POST_span_elems <- rvest::html_text2(POST_span_elems)
  str_not_found_in_db <- "list_not_found"
  str_not_found_at_all <- "list_not_found_at_all"

  lapply(
    X = list(str_not_found_in_db, str_not_found_at_all),
    FUN = \(x) {
      proteins <- POST_span_elems[which(POST_span_elems_id == x)] |>
        strsplit(split = ", ") |>
        unlist() |>
        stringr::str_remove_all(pattern = "\n")
      found <- ifelse(x == "list_not_found",
                      yes = "not found in database",
                      no = "not found at all")
      if (!length(proteins) == 0) {
        out <- data.frame(Query_identifier = proteins,
                          Found_in_SwissPalm = found_as_factor(found))
        out[, swissPalm_table_colnames()[-1]] <- NA
        out_ordered <- c(swissPalm_table_colnames(), "Found_in_SwissPalm")
        out[, out_ordered]
      } else {
        NULL
      }
    }
  ) |>
    do.call(what = "rbind")
}

#' @keywords internal
swissPalm_table_colnames <- function() {
  invisible(
     c("Query_identifier", "UniProt_AC", "UniProt_ID", "UniProt_status",
       "Organism", "Gene_names","Description",
       "Number_of_palmitoyl_proteomics_articles",
       "Number_of_palmitoyl_proteomics_studies_where_the_protein_appears_in_a_high_confidence_hit_list",
       "Number_of_technique_categories_used_in_palmitoyl_proteomics_studies",
       "Technique_categories_used_in_palmitoyl_proteomics_studies",
       "Number_of_targeted_studies", "Targeted_studies__PMIDs", "PATs", "APTs",
       "Number_of_sites", "Sites_in_main_isoform", "Number_of_isoforms",
       "Max_number_of_cysteines",
       "Max_number_of_cysteines_in_TM_or_cytosolic_domain",
       "Predicted_to_be_S_palmitoylated",
       "Predicted_to_be_S_palmitoylated_in_cytosolic_domains",
       "Protein_has_hits_in_SwissPalm",
       "Orthologs_of_this_protein_have_hits_in_SwissPalm")
  )
}

#' Generate list-columns where necessary in SwissPalm tables
#' @keywords internal
convert_swissPalm_table_listcols <- function(sp_tbl) {
  col2list <- function(col, as_numeric = FALSE) {
    col <- lapply(X = as.character(col),
                  FUN = \(x) {
                    if (is.na(x) || x == "") {
                      out <- NA
                    } else {
                      out <- unlist(strsplit(x, split = ", "))
                    }
                    if (as_numeric) {
                      as.numeric(out)
                    } else out
                  })
  }
  sp_tbl$Gene_names <- col2list(sp_tbl$Gene_names)
  sp_tbl$Targeted_studies__PMIDs <- col2list(sp_tbl$Targeted_studies__PMIDs)
  sp_tbl$Technique_categories_used_in_palmitoyl_proteomics_studies <-
    col2list(sp_tbl$Technique_categories_used_in_palmitoyl_proteomics_studies)
  sp_tbl$PATs <- col2list(sp_tbl$PATs)
  sp_tbl$APTs <- col2list(sp_tbl$APTs)
  sp_tbl$Sites_in_main_isoform <- col2list(sp_tbl$Sites_in_main_isoform,
                                           as_numeric = TRUE)
  sp_tbl
}
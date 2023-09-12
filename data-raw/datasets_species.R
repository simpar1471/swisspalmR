sp_session <- "https://swisspalm.org/proteins/refresh_form?first_load=true" |>
  rvest::session()
sp_content1 <- httr::content(x = sp_session$response, as = "text") |>
  strsplit(split = "<select name=") |>
  unlist() |>
  unname()

swisspalm_menu_html2vector <- function(element_id) {
  reqd_html <- stringr::str_detect(
    sp_content1,
    pattern = paste0('"', element_id, '" id="', element_id, '"')
  )
  reqd_html <- sp_content1[reqd_html] |>
    stringr::str_remove(pattern = ".*>(?=<option)") |>
    strsplit(split = "\n") |>
    unlist() |>
    unname()
  select_start <- 1
  select_end <- which(stringr::str_detect(reqd_html,
                                    pattern = "</select>$"))
  reqd_html <- reqd_html[select_start:select_end]
  values <- stringr::str_extract(reqd_html, pattern = '(?<=value=\\").*(?=\\")')
  names(values) <- stringr::str_extract(reqd_html, pattern = '(?<=>).*(?=<)') |>
    stringr::str_remove(pattern = "</option>$")
  values
}

datasets <- swisspalm_menu_html2vector(element_id = "dataset")
species <- swisspalm_menu_html2vector(element_id = "organism_id")

usethis::use_data(datasets, overwrite = TRUE)
usethis::use_data(species, overwrite = TRUE)
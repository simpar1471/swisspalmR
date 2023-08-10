sp_session <- "https://swisspalm.org/proteins/refresh_form?first_load=true" |>
  rvest::session() |>
sp_content1 <- httr::content(x = sp_session$response, as = "text") |>
  rvest::read_html(x = sp_session, as = "text")

datasets <- sp_search$fields$dataset$options
species <- sp_search$fields$organism_id$options
usethis::use_data(datasets, overwrite = TRUE)
usethis::use_data(species, overwrite = TRUE)
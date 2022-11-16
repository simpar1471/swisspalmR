#' Get palmitoylation data from SWISSpalm
#'
#' @param protein.identifiers Character vector with protein identifiers. Should be an ID type supported by SWISSpalm (https://swisspalm.org/file_formats).
#' @param download_dir Directory in which temporary files will be downloaded. Defaults to R temporary directory.
#' @param dataset.value Which dataset should SWISSpalm use? Key-value pairs are in \[swisspalm::dataset_values]. Default = 1 (all datasets)
#' @param species.value Which species should SWISSpalm search for? Key-value pairs for species are in \[swisspalm::species_values]. Default = 0 (all species)
#' @param verbose If TRUE, send status messages to the console.
#' @return Data frame containing palmitoylation data for proteins in protein.identifiers.
#' @references SwissPalm: Protein Palmitoylation database. Mathieu Blanc*, Fabrice P.A. David*, Laurence Abrami, Daniel Migliozzi, Florence Armand, Jérôme Burgi and F. Gisou van der Goot. F1000Research. (https://doi.org/10.12688/f1000research.6464.1)
#' @importFrom binman list_versions
#' @importFrom data.table fread fwrite
#' @importFrom RSelenium rsDriver
#' @export
getSWISSpalmData <- function(protein.identifiers, download_dir = tempdir(), dataset.value = 1, species.value = 0, verbose = F)
{
  if (!dataset.value %in% swisspalmR::dataset_values) stop("The value given for dataset.value is not in swisspalmR::dataset_values")
  if (!species.value %in% swisspalmR::species_values) stop("The value given for species.value is not in swisspalmR::species_values")

  input_file <- tempfile(pattern = "", fileext = ".txt")
  if (verbose) cat(paste0("\nSaving SWISSpalm input file to ", input_file, "..."))
  if (!file.exists(input_file)) data.table::fwrite(list(protein.identifiers), file = input_file)
  if (verbose) cat("\t Saved.\n")
  output_file <- file.path(download_dir, "query_result.txt")

  # Start RSelenium driver
  rselenium_ext_caps <- list(chromeOptions = list(prefs = list("download.prompt_for_download" = FALSE,
                                                               "download.default_directory" = download_dir),
                                                  args = list("--headless")))
  available_vers <- binman::list_versions(appname = "chromedriver")
  tryCatch({
    system(command = "taskkill /im java.exe /f", intern = FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE)
  }, warning = function(w) {
      if (verbose) cat(paste0("\n", w))
  }, error = function(e) {
      if (verbose) cat(paste0("\n", e))
  }, finally = {
    rsdriver <- RSelenium::rsDriver(browser = "chrome",
                                    chromever = available_vers$win32[length(available_vers)],
                                    extraCapabilities = rselenium_ext_caps,
                                    verbose = FALSE)
  })

  # Make sure to kill java even if the function exists early
  if (grepl(x = Sys.info()["sysname"], pattern = "Windows")) {
    on.exit(expr = {
      if (verbose) cat(paste0("Removing temporary files at: ", download_dir, "\n"))
      unlink(input_file)
      if (verbose) cat("Stopping RSelenium server...")
      rsdriver$server$stop()
      if (verbose) cat("\tStopped.\n")
    })
  }

  SWISSpalm_driver <- rsdriver[["client"]]
  SWISSpalm_driver$navigate("https://swisspalm.org/proteins?batch_search=1")

  Sys.sleep(time = 2)

  # Send the file we want to upload #
  file_input <- SWISSpalm_driver$findElement(using = "id", value = "file")
  file_input$sendKeysToElement(list(input_file))
  # Set the dataset we want to use #
  dataset_value <- toString(dataset.value)
  dataset <- SWISSpalm_driver$findElement(using = 'xpath', paste0('//*/option[@value = "', dataset_value, '"]'))
  dataset$clickElement()
  # Set the species we want to use #
  if (species.value != 0) {
    species_value <- toString(species.value) # IDs can be found by inspecting SWISSpalm.org/proteins HTML
    species <- SWISSpalm_driver$findElement(using = 'xpath', paste0('//*/option[@value = "', species_value, '"]'))
    species$clickElement()
  }
  # Click the search button to generate results #
  search_button <- SWISSpalm_driver$findElement(using = "id", value = "batch_search_btn")
  search_button$clickElement()

  Sys.sleep(time = 10) # Wait for results to load

  # Extract list of symbols not found in database IF PRESENT #
  not_found_in_database <- NA_character_
  nf_in_db <- SWISSpalm_driver$findElements(using = "id", value = "btn-list_not_found_at_all")
  if(length(nf_in_db))
{
    if (verbose) message("Retrieving symbols not in database")
    SWISSpalm_driver$findElement(using = "id", value = "btn-list_not_found_at_all")$clickElement()
    Sys.sleep(time = 0.5)
    elem_nf_in_db <- SWISSpalm_driver$findElement(using = "id", value = "list_not_found_at_all")
    not_found_in_database <- strsplit(x = elem_nf_in_db$getElementText()[[1]], split = ", ")[[1]]
    Sys.sleep(time = 0.05)
    SWISSpalm_driver$findElement(using = "id", value = "btn-list_not_found_at_all")$clickElement()
  }

  # Extract list of symbols not identified in dataset IF PRESENT #
  not_found_in_dataset <- NA_character_
  nf_in_ds <- SWISSpalm_driver$findElements(using = "id", value = "btn-list_not_found")
  if(length(nf_in_ds))
  {
    if (verbose) message("Retrieving symbols not in dataset")
    SWISSpalm_driver$findElement(using = "id", value = "btn-list_not_found")$clickElement()
    Sys.sleep(time = 0.5)
    elem_nf_in_ds <- SWISSpalm_driver$findElement(using = "id", value = "list_not_found")
    not_found_in_dataset <- strsplit(x = elem_nf_in_ds$getElementText()[[1]], split = ", ")[[1]]
    Sys.sleep(time = 0.05)
    SWISSpalm_driver$findElement(using = "id", value = "btn-list_not_found")$clickElement()
  }

  Sys.sleep(time = 5) # Give the server a break

  # Download output file as long as some proteins were found in SWISSpalm #
  if (all(protein.identifiers %in% c(not_found_in_dataset, not_found_in_database))) {
    if (verbose) message("\nNone of the supplied accessions were found in the SWISSpalm database. Exiting...")
    return(list(palmData = NA_character_, notInDatabase = not_found_in_database, notInDataset = not_found_in_dataset))
  }


  output_type <- "download_text"
  download_button <- SWISSpalm_driver$findElement(using = "id", value = output_type)
  download_button$clickElement()
  while (!file.exists(output_file)) {
    Sys.sleep(time = 3)
  }

  out_li <- list(palmData = data.table::fread(input = normalizePath(output_file)),
                 notInDatabase = not_found_in_database, notInDataset = not_found_in_dataset)

  # Clear temporary files and on.exit() cache #
  on.exit()
  if (verbose) cat(paste0("Removing temporary files at: ", download_dir, "\n"))
  unlink(input_file)
  unlink(output_file)
  if (verbose) cat("Stopping RSelenium server...")
  rsdriver$server$stop()
  if (verbose) cat("\tStopped.\n")

  return(out_li)
}
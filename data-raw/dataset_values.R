# Get SWISSpalm organisms from inspecting drop-down menu in
# https://swisspalm.org/proteins
html <- httr2::request()
htmlstr <- '<option value="all">Dataset 1: All proteins</option> <option value="pred">Dataset 2: Proteins predicted to be palmitoylated</option> <option value="palm">Dataset 3: Palmitoylation validated or found in at least 1 palmitoyl-proteome (SwissPalm annotated)</option> <option value="targ">Dataset 4: Palmitoylation validated proteins</option> <option value="meth">Dataset 5: Palmitoylation validated proteins or found in palmitoyl-proteomes using 2 independent methods</option> <option value="meth2">Dataset 6: Found in palmitoyl-proteomes using 2 independent methods</option> <option value="validated_dataset">Dataset 7: Dataset 6 grouped by gene</option>'
dataset_vals <- strsplit(x = htmlstr,
                         split = "> <")[[1]] |>
  stringr::str_remove(pattern = "<?option value=\"")
dataset_values <- stringr::str_extract(string = dataset_vals,
                                              pattern = "^.{1,}(?=\")")
names(dataset_values) <- stringr::str_remove_all(dataset_vals,
                                                 pattern = '^.{1,}">|<\\/option>?')
rm(htmlstr, dataset_vals)
usethis::use_data(dataset_values, overwrite = TRUE)
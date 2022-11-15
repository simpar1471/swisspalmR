dataset_values <- c(
  "All proteins" = 1,
  "Proteins predicted to be palmitoylated" = 2,
  "Palmitoylation validated or found in at least 1 palmitoyl-proteome (SwissPalm annotated)" = 3,
  "Palmitoylation validated proteins" = 4,
  "Palmitoylation validated proteins or found in palmitoyl-proteomes using 2 independent methods" = 5,
  "Found in palmitoyl-proteomes using 2 independent methods" = 6,
  "Dataset 6 grouped by gene" = 7)

usethis::use_data(dataset_values, overwrite = TRUE)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# swisspalmR

<!-- badges: start -->

[![R-CMD-check](https://github.com/simpar1471/swisspalmTemp/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/simpar1471/swisspalmTemp/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The swisspalmR package lets you retrieve SWISSpalm data programatically
from R using headless chromedriver sessions.

## Installation

You can install the development version of swisspalmR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("simpar1471/swisspalmTemp")
```

## Example

To query the SWISSpalm database, get your protein accessions into a
vector. You can then check them against the SWISSpalm database with
`getSWISSpalmData()`. You'll get back a list with three entries:
1. palmData: A table available SWISSpalm data for each protein 
accession in the selected dataset + species
2. notInDatabase: A character vector with protein accessions which 
are not in SWISSpalm
3. notInDataset: A character vector with protein accessions which 
are in SWISSpalm but not in the selected dataset + species

For example:
``` r
input_uniprot <- c("P05067", "O00161", "P04899")
spalm_data_all_species <- swisspalmR::getSWISSpalmData(input_uniprot)
head(dplyr::tibble(spalm_data_all_species$palmData)); head(spalm_data_all_species[2:3])
#> # A tibble: 3 × 24
#>   Query identi…¹ UniPr…² UniPr…³ UniPr…⁴ Organ…⁵ Gene …⁶ Descr…⁷ Numbe…⁸ Numbe…⁹
#>   <chr>          <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <chr>     <int>
#> 1 P04899         P04899  GNAI2_… Review… Homo s… GNAI2B… Guanin… 17 of …      11
#> 2 P05067         P05067  A4_HUM… Review… Homo s… AD1, A… Amyloi… 2 of 22       3
#> 3 O00161         O00161  SNP23_… Review… Homo s… SNAP23  Synapt… 20 of …      11
#> # … with 15 more variables:
#> #   `Number of technique categories used in palmitoyl-proteomics studies` <int>,
#> #   `Technique categories used in palmitoyl-proteomics studies` <chr>,
#> #   `Number of targeted studies` <int>, `Targeted studies (PMIDs)` <chr>,
#> #   PATs <chr>, APTs <chr>, `Number of sites` <int>,
#> #   `Sites in main isoform` <chr>, `Number of isoforms` <int>,
#> #   `Max number of cysteines` <int>, …
#> $notInDatabase
#> [1] NA
#> 
#> $notInDataset
#> [1] NA
```

You can test your protein accessions against specific datasets or
species in SWISSpalm using the `dataset.value` and `species.value`
parameters:

``` r
# Checking against only SARS-Cov
spalm_data_only_sarscov <- swisspalmR::getSWISSpalmData(input_uniprot,
                                                        dataset.value = 1,
                                                        species.value = swisspalmR::species_values["SARS-CoV"])
head(spalm_data_only_sarscov)
#> $palmData
#> [1] NA
#> 
#> $notInDatabase
#> [1] NA
#> 
#> $notInDataset
#> [1] "O00161" "P04899" "P05067"
```

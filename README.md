
<!-- README.md is generated from README.Rmd. Please edit that file -->

# swisspalmR <img src="man/figures/logo.png" align="right" height="200" alt="" />

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
`getSWISSpalmData()`. You’ll get back a list with three entries: 1.
palmData: A table available SWISSpalm data for each protein accession in
the selected dataset + species 2. notInDatabase: A character vector with
protein accessions which are not in SWISSpalm 3. notInDataset: A
character vector with protein accessions which are in SWISSpalm but not
in the selected dataset + species

For example:

``` r
input_uniprot <- c("P05067", "O00161", "P04899")
spalm_data_all_species <- swisspalmR::getSWISSpalmData(input_uniprot)
head(dplyr::tibble(spalm_data_all_species$palmData)); head(spalm_data_all_species[2:3])
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
```


<!-- README.md is generated from README.Rmd. Please edit that file -->

# swisspalmR: Access SwissPalm data directly from R <img src="man/figures/logo.png" align="right" height="138" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/simpar1471/swisspalmTemp/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/simpar1471/swisspalmTemp/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The swisspalmR package lets you retrieve SWISSpalm data within R using
HTTP commands.

## Installation

You can install the development version of swisspalmR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("simpar1471/swisspalmR")
```

## Example

To query the SWISSpalm database, get your protein accessions into a
vector. You can then check them against the with the `swissPalm()`
command. You’ll get back a dataframe with rows for each : 1. palmData: A
table available SWISSpalm data for each protein adccession in the
selected dataset + species 2. notInDatabase: A character vector with
protein accessions which are not in SWISSpalm 3. notInDataset: A
character vector with protein accessions which are in SWISSpalm but not
in the selected dataset + species

For example:

``` r
protein_ids <- c("P05067", "O00161", "P04899")
swisspalmR::swissPalm(protein_ids)
```

You can test your protein accessions against specific datasets or
species in SwissPalm using the `dataset` and `species` parameters. Valid
values for `dataset` and `species` can be found in the package objects

``` r
# Checking against only SARS-Cov
spalm_data_only_sarscov <- swisspalmR::swissPalm(protein_ids,
                                                 dataset = 1,
                                                 species = swisspalmR::species["SARS-CoV"])
#> Warning: "1" is not a valid `dataset` value. Setting "1" to default: `all`.
#> ℹ Valid `dataset` values can be found in `swisspalmR::datasets`.
head(spalm_data_only_sarscov)
#>   Query_identifier                 Found
#> 1           O00161 not found in database
#> 2           P04899 not found in database
#> 3           P05067 not found in database
```

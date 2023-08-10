
<!-- README.md is generated from README.Rmd. Please edit that file -->

# swisspalmR: Access SwissPalm data through R <img src="man/figures/logo.png" align="right" height="138"/>

<!-- badges: start -->

[![R-CMD-check](https://github.com/simpar1471/swisspalmTemp/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/simpar1471/swisspalmTemp/actions/workflows/R-CMD-check.yaml)
[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

<!-- badges: end -->

swisspalmR is a small package with one purpose: it retrieves
S-palmiotylation data from the SwissPalm database using `httr2`, `rvest`
and `curl`.

## Installation

You can install the development version of swisspalmR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("simpar1471/swisspalmR")
```

## Examples

To query the SwissPalm database, get some protein accessions into a
vector. The proteins must be supported by SwissPalm, i.e. a UniProt AC,
UniProt secondary AC, UniProt ID, UniProt gene name, Ensembl protein,
Ensembl gene, Refseq protein ID, IPI ID, UniGene ID, PomBase ID, MGI ID,
RGD ID, TAIR protein ID, or EuPathDb ID.

Once in a vector you can check them against SwissPalm the with the
`swissPalm()` function You’ll get back a dataframe with rows for each
protein ID supplied to the function, detailing various aspects of
S-palmitoylation for each protein in SwissPalm. For example:

``` r
protein_ids <- c("P05067", "O00161", "P04899", "P98019")
swisspalmR::swissPalm(protein_ids)
#>   Query identifier Found UniProt AC  UniProt ID   Organism
#> 1           O00161 found     O00161 SNP23_HUMAN H. sapiens
#> 2           P04899 found     P04899 GNAI2_HUMAN H. sapiens
#> 3           P05067 found     P05067    A4_HUMAN H. sapiens
#> 4           P98019 found     P98019  COX2_ANAPL    M. duck
#>                                  Protein name Found in palmitoyl-proteomes
#> 1 Synaptosomal-associated protein 23, SNAP-23                        20/22
#> 2        Guanine nucleotide-binding protein G                        17/22
#> 3         Amyloid-beta precursor protein, APP                         2/22
#> 4  Cytochrome c oxidase subunit 2, EC 7.1.1.9                          0/0
#>   Techniques Times validated
#> 1          4               4
#> 2          4               7
#> 3          2               4
#> 4          0               0
#>                                                    DHHC-PATs & APTs Sites
#> 1                                                                       6
#> 2 ZDHC3_MOUSE, ZDHC7_MOUSE, ZDHC2_MOUSE, ZDH21_MOUSE\n  LYPA1_HUMAN     3
#> 3                ZDHC7_MOUSE, ZDH21_MOUSE, ZDHC7_HUMAN, ZDH21_HUMAN     2
#> 4                                                                       0
#>   Predicted sites Cys Orthologs
#> 1             Yes   6       Yes
#> 2             Yes  11       Yes
#> 3             Yes  18       Yes
#> 4              No   3        No
```

You can test your protein accessions against specific datasets or
species in SwissPalm using the `dataset` and `species` parameters. Valid
values for `dataset` and `species` can be found in the package objects
`swisspalmR::datasets` and `swisspalmR::species`.

``` r
# Checking against only mallard ducks
mallard <- swisspalmR::species["Mallard duck"]
spalm_data_only_mallards <- swisspalmR::swissPalm(protein_ids, 
                                                  species = mallard)
head(spalm_data_only_mallards)
#>   Query identifier                 Found UniProt AC UniProt ID Organism
#> 1           P98019                 found     P98019 COX2_ANAPL  M. duck
#> 2             <NA> not found in database       <NA>       <NA>     <NA>
#> 3             <NA> not found in database       <NA>       <NA>     <NA>
#> 4             <NA> not found in database       <NA>       <NA>     <NA>
#>                                 Protein name Found in palmitoyl-proteomes
#> 1 Cytochrome c oxidase subunit 2, EC 7.1.1.9                          0/0
#> 2                                       <NA>                         <NA>
#> 3                                       <NA>                         <NA>
#> 4                                       <NA>                         <NA>
#>   Techniques Times validated Sites Predicted sites Cys Orthologs
#> 1          0               0     0              No   3        No
#> 2         NA              NA    NA            <NA>  NA      <NA>
#> 3         NA              NA    NA            <NA>  NA      <NA>
#> 4         NA              NA    NA            <NA>  NA      <NA>
#>   Query.identifier
#> 1             <NA>
#> 2           O00161
#> 3           P04899
#> 4           P05067
```

Note that `swissPalm()` is
[memoised](https://memoise.r-lib.org/index.html) - results are cached
and returned if the same inputs are provided to `swissPalm()` in one
session. This way, SwissPalm can return results to users faster. If you
want the `swissPalm()` functions to ‘forget’ previous results, use
`memoise::forget(swissPalm)` .

## Known issues

- Using an input vector with more than 100 values may cause a table to
  be returned which does not have a row for all proteins in the query.
  You can get around this by splitting your protein ID vector into a
  list of vectors with length \< 100, then running over this list with
  `apply()` or `purrr::map()`. If doing this, please use `Sys.sleep()`
  to force R to wait between making requests, and thereby prevent the
  likelihood of overwhelming the SwissPalm server.

## Upcoming features

The SwissPalm website offers downloads for palmitoylation data in three
forms: text, Excel, and FASTA. I hope to emulate this behaviour with
extra functions, but for now I have not been able to represent the
necessary HTTP commands in R.

## Credit and copyright

The SwissPalm database is available under a [Creative Commons BY-NC-ND
license](https://creativecommons.org/licenses/by-nc-nd/4.0/). SwissPalm
reference: [SwissPalm: Protein Palmitoylation
database.](http://f1000research.com/articles/4-261/v1) Mathieu Blanc*,
Fabrice P.A. David*, Laurence Abrami, Daniel Migliozzi, Florence Armand,
Jérôme Burgi and F. Gisou van der Goot. F1000Research.

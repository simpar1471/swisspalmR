# swisspalmR 0.0.2
* `swissPalm()` now accesses more palmitoylation data.
  * This is done by downloading the raw text file from the SwissPalm database, 
    then formatting this with `read.table()`.
  * The data frame returned by `swissPalm()` will now have list-columns where 
    there can be multiple returned values, e.g. the `Sites_in_main_isoform` 
    column.
* Better (i.e. actual) unit testing with `testthat`.
* A changed number of imports thanks to some refactoring.

## 0.0.1.9000
* In development: `swissPalm()` function for getting data frames 
  with palmitoylation data from SwissPalm database

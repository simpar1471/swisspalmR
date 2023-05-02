# test_that(desc = "Incorrect dataset/species values fail", {
#   expect_error(getSWISSpalmData(c("P05067", "O00161", "P04899"), dataset.value = 0),
#                regexp =  "not in swisspalmR::dataset_values")
#   expect_error(getSWISSpalmData(c("P05067", "O00161", "P04899"), species.value = 5),
#                regexp =  "not in swisspalmR::species_values")
# })
#
# test_that(desc = "getSWISSpalmData is memoised", {
#   expect_true(memoise::is.memoised(getSWISSpalmData))
# })
#
# test_that(desc = "getSWISSpalmData returns expected values", {
#   expect_equal(object = getSWISSpalmData(c("P05067", "O00161", "P04899")),
#                expected = readRDS(test1, file="tests/testthat/fixtures/test1.rds"))
# })
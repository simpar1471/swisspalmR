good_inputs <- c("P05067", "P04899", "O00161", "P98019")
my_rand_strings <- function(n) {
  a <- do.call(paste0, replicate(n = 5, sample(LETTERS, n, replace = TRUE),
                                 simplify = FALSE))
  paste0(a,
         sprintf(fmt = "%04d", sample(x = 9999, n, TRUE)),
         sample(LETTERS, n, TRUE))
}

test_that(desc = "swissPalm() is memoised", {
  expect_true(memoise::is.memoised(swissPalm))
})

# Testing badly formatted params + default checking ----------------------------
test_that(desc = "swissPalm fails with bad query IDs", {
  bad_input_length <- character()
  expect_error(
    swissPalm(bad_input_length),
    regexp = "`query_id` must have length >= 1"
  )
  bad_input_not_char <- c(TRUE, FALSE)
  expect_error(
    swissPalm(bad_input_not_char),
    regexp = "`query_id` must be a character vector"
  )
})

test_that(desc = "swissPalm sets bad species/dataset to correct defaults", {
  expect_warning(
    swissPalm(good_inputs, species = "invalid species"),
    regexp = "Setting \"invalid species\" to default: ``"
  )
  expect_warning(
    swissPalm(good_inputs, dataset = "invalid dataset"),
    regexp = "Setting \"invalid dataset\" to default: `all`"
  )
})

# Testing good/bad query IDs ---------------------------------------------------

test_that(desc = "test swissPalm when all inputs should be found", {
  expect_no_error(
    swissPalm(good_inputs)
  )
})

test_that(desc = "test swissPalm with specific dataset/species", {
  expect_no_error(
    swissPalm(good_inputs, species = swisspalmR::species["Mallard duck"])
  )
  expect_no_error(
    swissPalm(good_inputs, dataset = swisspalmR::datasets[3])
  )
})

test_that(desc = "test swissPalm when some inputs should be found", {
  n_good_inputs <- length(good_inputs)
  n_bad_inputs <- round(abs(rnorm(n = 1, sd = 10)))
  bad_inputs <- my_rand_strings(n_bad_inputs)
  out <- swissPalm(c(good_inputs, bad_inputs))

  cells_notNA <- !is.na(out[, 2])
  cells_NA <- is.na(out[, 2])

  expect_equal(sum(cells_notNA), n_good_inputs)
  expect_equal(sum(cells_NA), n_bad_inputs)
})

test_that(desc = "test swissPalm when no inputs should be found", {
  out <- swissPalm(c("wrong", "false", "P2534890", "notfound"))
  # No data will be present, i.e. NA in all rows except Query_Identifier
  expect_true(all(is.na(out[, c(-1, -length(out))])))
})

test_that(desc = "test swissPalm with different types of query ID", {
  uniprotAC <- swissPalm(c("P05067", "P04899", "O00161", "P98019"))
  uniprotID <- swissPalm(uniprotAC$UniProt_ID)
  expect_equal(
    object = uniprotAC[, -1], expected = uniprotID[, -1]
  )
})
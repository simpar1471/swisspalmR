is_invalid_param <- function(param, valid_values, default) {
  if (!param %in% valid_values) {
    param_name <- deparse(substitute(param))
    valid_values_name <- deparse(substitute(valid_values))
    cli::cli_alert_warning(
      c("{.var {param}} is not a valid {.var {param_name}} value.",
        "i" = paste0("Setting {.var {param}} to default: {.var {default}}."))
    )
    TRUE
  } else FALSE
}
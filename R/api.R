
#' Example ASCVD schema
#'
#' @export
ascvd_schema <- function(...) {
  schema_ascvd(...)
}

#' Example ASCVD model bundle
#'
#' Convenience wrapper around bundle_ascvd().
#'
#' @export
ascvd_model_bundle <- function(schema = ascvd_schema(),
                              ctx = list(time_unit = "unitless")) {
  bundle_ascvd(schema = schema, ctx = ctx)
}

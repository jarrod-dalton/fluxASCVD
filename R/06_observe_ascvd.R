# Observe is optional and not required for most models.
# We leave it as a no-op but include the file to mirror the template.

#' Observe hook for the ASCVD example (no-op)
#' @keywords internal
observe_ascvd <- function(patient, event, ctx = NULL) {
  NULL
}

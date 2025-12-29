
#' Transition logic for the ASCVD example model
#'
#' Returns a "patch" list (possibly namespaced by scope) compatible with
#' patientSimCore merge/update utilities.
#'
#' @export
transition_ascvd <- function(patient, event, ctx) {
  et <- event$event_type
  t <- event$time

  # Simple guard: keep time unit in ctx to avoid noisy warnings in examples/tests.
  if (is.null(ctx$time_unit) || !nzchar(as.character(ctx$time_unit))) {
    ctx$time_unit <- "unitless"
  }

  if (et == "clinic_visit") {
    sbp0 <- as.numeric(patient$state("sbp"))
    dbp0 <- as.numeric(patient$state("dbp"))

    # Gentle random walk (example only)
    sbp <- sbp0 + stats::rnorm(1, mean = -5, sd = 10)
    dbp <- dbp0 + stats::rnorm(1, mean = -2, sd = 6)

    # Occasionally order a BMP (example only)
    order <- stats::runif(1) < 0.25
    patch <- list(
      sbp = sbp,
      dbp = dbp,
      last_clinic_time = t
    )
    if (order) patch$bmp_order_time <- t
    return(patch)
  }

  if (et == "bmp") {
    # BMP "result" arrives: mark measured and set LDL (example only)
    ldl <- as.numeric(stats::rnorm(1, mean = 120, sd = 25))
    return(list(
      bmp_measured = t,
      ldl = ldl
    ))
  }

  if (et == "ascvd_event") {
    # Mark a generic CVD event. A real package would likely set a flag and/or
    # emit event-specific state changes.
    return(list(
      ascvd_event = TRUE
    ))
  }

  stop("Unknown event_type: ", et)
}

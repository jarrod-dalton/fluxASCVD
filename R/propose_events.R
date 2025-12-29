# Event proposal helpers for the ASCVD example model.

propose_events_ascvd <- function(patient, ctx) {
  list(
    propose_clinic_visit(patient, ctx),
    propose_bmp(patient, ctx),
    propose_ascvd_event(patient, ctx)
  )
}

propose_clinic_visit <- function(patient, ctx) {
  t <- patient$last_time
  interval <- ctx$params$clinic_interval
  if (is.null(interval) || !is.finite(interval) || interval <= 0) interval <- 0.5

  list(
    process_id = "clinic",
    time_next = t + interval,
    event_type = "clinic_visit"
  )
}

propose_bmp <- function(patient, ctx) {
  # A BMP is only proposed if it has been ordered but not yet measured.
  s <- patient$as_list(c("bmp_order_time", "bmp_measured_time"))

  if (is.na(s$bmp_order_time) || !is.na(s$bmp_measured_time)) {
    return(list(process_id = "bmp", time_next = Inf, event_type = NA_character_))
  }

  delay <- ctx$params$bmp_result_delay
  if (is.null(delay) || !is.finite(delay) || delay <= 0) delay <- 0.05

  list(
    process_id = "bmp",
    time_next = s$bmp_order_time + delay,
    event_type = "bmp"
  )
}

propose_ascvd_event <- function(patient, ctx) {
  # If the model is deactivated via model_active, propose no events.
  if ("model_active" %in% names(patient$schema)) {
    ma <- patient$state("model_active")
    if (is.list(ma) && isFALSE(ma[["ascvd"]])) {
      return(list(process_id = "ascvd", time_next = Inf, event_type = NA_character_))
    }
  }

  t <- patient$last_time
  hazard <- ctx$params$ascvd_hazard
  if (is.null(hazard) || !is.finite(hazard) || hazard <= 0) hazard <- 0.01

  dt <- stats::rexp(1, rate = hazard)
  list(
    process_id = "ascvd",
    time_next = t + dt,
    event_type = "ascvd_event"
  )
}

# patientSimASCVD
#
# 03_propose_events_ascvd.R
#
# propose_events() suggests the next event time/type for each independent
# "process" in the model. patientSimCore chooses the minimum time_next across
# processes (with deterministic tie-breaking).
#
# Important: proposals must be a named list keyed by process_id. Each element
# must include:
# - time_next: numeric scalar, finite
# - event_type: character scalar
# Additional fields are allowed.

propose_events_ascvd <- function(patient, ctx = NULL) {
  t <- patient$last_time

  # Clinic visits happen at a fixed cadence.
  # Default cadence is 1 time-unit unless overridden by ctx.
  cadence <- 1
  if (!is.null(ctx) && !is.null(ctx$clinic_cadence)) cadence <- as.numeric(ctx$clinic_cadence)
  clinic_next <- t + cadence

  out <- list(
    clinic = list(
      time_next = clinic_next,
      event_type = "clinic_visit"
    )
  )

  # A one-time MI event at a fixed absolute time, used to demonstrate
  # "follow-up can stop without implying death".
  #
  # The MI occurs only while phase == "baseline" and only if it lies in the future.
  st <- patient$state()
  if (identical(st[["phase"]], "baseline")) {
    mi_time <- 2
    if (!is.null(ctx) && !is.null(ctx$mi_time)) mi_time <- as.numeric(ctx$mi_time)

    if (t < mi_time) {
      out$ascvd <- list(
        time_next = mi_time,
        event_type = "mi"
      )
    }
  }

  out
}

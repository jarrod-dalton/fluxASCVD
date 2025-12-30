# patientSimASCVD
#
# 05_stop_ascvd.R
#
# stop() decides when the engine should terminate simulation for a patient.
#
# Baseline semantics to preserve:
# - Death is represented by alive == FALSE, and that is biological truth.
# - A model may stop follow-up without death (e.g., after a non-fatal event).
#   After follow-up stop, downstream summaries treat later state as undefined (NA).

stop_ascvd <- function(patient, event, ctx = NULL) {
  et <- event$event_type
  st <- patient$state()

  # Stop immediately if the patient has died.
  if (isFALSE(st[["alive"]])) return(TRUE)

  # Demonstrate follow-up stop after a non-fatal MI.
  if (identical(et, "mi")) return(TRUE)

  # Optionally cap simulation at a maximum time.
  if (!is.null(ctx) && !is.null(ctx$t_max)) {
    if (patient$last_time >= as.numeric(ctx$t_max)) return(TRUE)
  }

  FALSE
}

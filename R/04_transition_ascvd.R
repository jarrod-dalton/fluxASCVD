# patientSimASCVD
#
# 04_transition_ascvd.R
#
# transition() applies the selected event to the patient state.
#
# Key convention:
# - Use patient$state() to read current scalar values.
# - Return a "changes" list with named values to update.
# - Do NOT manually increment time; patientSimCore owns the time axis.

transition_ascvd <- function(patient, event, ctx = NULL) {
  et <- event$event_type
  st <- patient$state()

  if (identical(et, "clinic_visit")) {
    # A toy blood pressure drift process.
    #
    # We intentionally use scalar access via patient$state()[[var]]
    # so this file remains stable against state object internals.
    sbp <- as.numeric(st[["sbp"]])
    dbp <- as.numeric(st[["dbp"]])

    # If state is missing (e.g., after follow-up stop), do nothing.
    if (is.na(sbp) || is.na(dbp)) return(list())

    # Mild regression to the mean + random noise.
    target_sbp <- if (!is.null(ctx) && !is.null(ctx$target_sbp)) as.numeric(ctx$target_sbp) else 125
    target_dbp <- if (!is.null(ctx) && !is.null(ctx$target_dbp)) as.numeric(ctx$target_dbp) else 78

    sbp_new <- sbp + 0.2 * (target_sbp - sbp) + stats::rnorm(1, mean = 0, sd = 4)
    dbp_new <- dbp + 0.2 * (target_dbp - dbp) + stats::rnorm(1, mean = 0, sd = 3)

    return(list(
      sbp = sbp_new,
      dbp = dbp_new
    ))
  }

  if (identical(et, "mi")) {
    # Non-fatal event: update phase but do NOT set alive = FALSE.
    return(list(
      phase = "post_mi"
    ))
  }

  # Unknown event type: no changes.
  list()
}

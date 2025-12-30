# patientSimASCVD
#
# 02_derived_vars_ascvd.R
#
# Derived variables are computed from patient state/history at snapshot time.
#
# Key idea (baseline): derived vars are *not* canonical state. They are computed
# on-demand when you call patient$snapshot(), patient$snapshot_at(), or
# patient$snapshot_at_time().
#
# Contract (from patientSimCore): each derived var is a function
#
#   f(patient, j, t) -> scalar (or NULL to omit)
#
# where:
#   - patient is the Patient R6 object
#   - j is the event index at which the snapshot is being taken
#   - t is the snapshot time (may differ from the event time in snapshot_at_time)
#
# This file includes two patterns:
#   1) a simple transformation of current state (pulse pressure)
#   2) history-based summaries (lag and rolling max)

ascvd_derived_vars <- function(schema = ascvd_schema()) {
  derived <- list()

  # ---------------------------------------------------------------------------
  # Pattern 1: simple state transformation
  # ---------------------------------------------------------------------------
  # Pulse pressure (SBP - DBP).
  derived$pp <- function(patient, j = patient$j, t = patient$last_time) {
    s <- patient$state_at(j, vars = c("sbp", "dbp"))
    sbp <- s[["sbp"]]
    dbp <- s[["dbp"]]
    if (is.na(sbp) || is.na(dbp)) return(NA_real_)
    as.numeric(sbp) - as.numeric(dbp)
  }

  # ---------------------------------------------------------------------------
  # Pattern 2: history-based derived variables
  # ---------------------------------------------------------------------------
  # These use patientSimCore::lag_of() and patientSimCore::derive(), which are
  # designed specifically for sparse history (only values at event times are stored).

  # last_sbp: previous recorded SBP value (1-step lag), excluding the current event.
  derived$last_sbp <- patientSimCore::lag_of(
    name = "last_sbp",
    target = patientSimCore::var("sbp"),
    k = 1,
    include_current = FALSE,
    force = TRUE,
    na_value = NA_real_
  )

  # max_sbp_3y: max SBP in the last 3 time units (assumes time is in years when
  # ctx$time_unit == "years" in the example/test setup).
  #
  # Notes:
  # - include_current = TRUE includes the current SBP value in the window.
  # - force = TRUE makes this return NA when there is no history yet.
  derived$max_sbp_3y <- patientSimCore::derive(
    name = "max_sbp_3y",
    target = patientSimCore::var("sbp"),
    lookback_t = 3,
    fn = "max",
    include_current = TRUE,
    force = TRUE,
    na_value = NA_real_
  )

  derived
}

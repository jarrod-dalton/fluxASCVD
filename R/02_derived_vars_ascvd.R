# patientSimASCVD
#
# 02_derived_vars_ascvd.R
#
# Derived variables are computed from patient state at snapshot time.
# This is optional, but it demonstrates how to add light transformations
# that remain downstream of canonical state updates.

ascvd_derived_vars <- function(schema = ascvd_schema()) {
  # NOTE: In this framework, derived variables are a *model concern*.
  # The core schema deliberately does not ship a universal set of
  # "default" derived variables, because what is considered derived is
  # model-specific. So we start from an empty set.
  derived <- list()

  # Pulse pressure (SBP - DBP) as a trivial example.
  derived$pp <- function(state) {
    sbp <- state[["sbp"]]
    dbp <- state[["dbp"]]
    if (is.na(sbp) || is.na(dbp)) return(NA_real_)
    as.numeric(sbp) - as.numeric(dbp)
  }

  derived
}

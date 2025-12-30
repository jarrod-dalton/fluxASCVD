# patientSimASCVD
#
# 02_derived_vars_ascvd.R
#
# Derived variables are computed from patient state at snapshot time.
# This is optional, but it demonstrates how to add light transformations
# that remain downstream of canonical state updates.

ascvd_derived_vars <- function(schema = ascvd_schema()) {
  # Start with any derived vars the core schema already defines.
  derived <- patientSimCore::default_derived_vars(schema = schema)

  # Pulse pressure (SBP - DBP) as a trivial example.
  derived$pp <- function(state) {
    sbp <- state[["sbp"]]
    dbp <- state[["dbp"]]
    if (is.na(sbp) || is.na(dbp)) return(NA_real_)
    as.numeric(sbp) - as.numeric(dbp)
  }

  derived
}

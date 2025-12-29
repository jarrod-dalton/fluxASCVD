
# ------------------------------------------------------------------------------
# derived_vars_ascvd(params = list())
#
# Define derived variables for patientSimASCVD.
#
# Contract:
#   Each derived var is a function f(patient, j, t) -> scalar (or NULL)
#
# Keep derived vars non-recursive (do not call patient$snapshot() inside).
# ------------------------------------------------------------------------------
derived_vars_ascvd <- function(params = list()) {

  bp_controlled <- function(patient, j, t) {
    sbp <- as.numeric(patient$state("sbp"))
    dbp <- as.numeric(patient$state("dbp"))
    if (anyNA(c(sbp, dbp))) return(NA)
    # Example threshold only
    isTRUE(sbp < 140 && dbp < 90)
  }

  n_no_show <- function(patient, j, t) {
    ev <- patient$events
    if (is.null(ev) || nrow(ev) == 0) return(0L)
    if (!("event_type" %in% names(ev))) return(0L)
    sum(ev$event_type == "clinic_no_show", na.rm = TRUE)
  }

  list(
    bp_controlled = bp_controlled,
    n_no_show = n_no_show
  )
}

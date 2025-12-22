# ------------------------------------------------------------------------------
# ASCVD ModelBundle constructor
# ------------------------------------------------------------------------------
ascvd_model_bundle <- function(params = list()) {
  list(
    propose_events = propose_events_ascvd,
    transition = transition_ascvd,
    stop = stop_ascvd
  )
}

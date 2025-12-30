# patientSimASCVD
#
# 07_bundle_ascvd.R
#
# The model bundle is the only object the engine needs.
# It collects the callbacks that define disease/process behavior.
#
# This keeps disease logic "thin":
# - no looping
# - no RNG discipline decisions
# - no summarization
#
# Those responsibilities live in patientSimCore and patientSimForecast.

ascvd_model_bundle <- function(schema = ascvd_schema()) {
  # Attach derived vars so patient snapshots include them.
  derived <- ascvd_derived_vars(schema = schema)

  list(
    schema = schema,
    derived_vars = derived,
    propose_events = propose_events_ascvd,
    transition = transition_ascvd,
    stop = stop_ascvd
  )
}

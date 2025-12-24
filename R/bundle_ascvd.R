# ------------------------------------------------------------------------------
# ascvd_model_bundle(params = list())
#
# Build the patientSimASCVD ModelBundle.
#
# Notes
# - Engine standardizes ctx$params:
#     * if user provides ctx$params, it is used
#     * else Engine will use bundle$params (below) if provided
# - init_patient() is called once at the start of Engine$run()
# ------------------------------------------------------------------------------

ascvd_model_bundle <- function(params = list()) {
  
  init_patient <- function(patient, ctx) {
    # Use ctx$params so derived vars align with any user overrides for this run.
    patientSimCore::check_derived(
      patient,
      derived_vars_ascvd(ctx$params),
      replace = FALSE
    )
    invisible(NULL)
  }
  
  list(
    # Optional defaults for ctx$params (Engine uses these if ctx$params not provided)
    params         = params,
    
    init_patient   = init_patient,
    propose_events = propose_events_ascvd,
    transition     = transition_ascvd,
    stop           = stop_ascvd,
    observe        = observe_ascvd
  )
}

# ------------------------------------------------------------------------------
# ascvd_model_bundle(params = list())
#
# Build the patientSimASCVD ModelBundle.
#
# init_patient() is called once at the start of Engine$run() and is used to
# register derived variables (idempotent by name).
# ------------------------------------------------------------------------------
ascvd_model_bundle <- function(params = list()) {

  init_patient <- function(patient, ctx) {
    patientSimCore::check_derived(patient, derived_vars_ascvd(params), replace = FALSE)
    invisible(NULL)
  }

  with_params <- function(ctx) {
    if (is.null(ctx)) ctx <- list()
    if (is.null(ctx$params)) ctx$params <- params
    ctx
  }

  list(
    init_patient  = init_patient,
    propose_events = function(patient, ctx) propose_events_ascvd(patient, with_params(ctx)),
    transition     = function(patient, event, ctx) transition_ascvd(patient, event, with_params(ctx)),
    stop           = function(patient, event, ctx) stop_ascvd(patient, event, with_params(ctx))
  )
}

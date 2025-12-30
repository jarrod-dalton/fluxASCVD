
#' Bundle for the ASCVD example model
#'
#' @export
bundle_ascvd <- function(schema = schema_ascvd(),
                         ctx = list(time_unit = "unitless")) {

  # A bundle is the single object the core simulation engine interacts with.
  # Think of it as a small "model API" with a few required callbacks.
  #
  # For teaching purposes, we keep this thin and explicit: every piece of model
  # behavior lives in a dedicated function referenced below.

  list(
    # Called once before the first event. Useful for caching, seeding RNG, etc.
    init = function(patient, ctx) invisible(NULL),

    # Return a list of "event proposals" (one per process) describing when the
    # next event could happen.
    propose_events = function(patient, ctx) propose_events_ascvd(patient, ctx),

    # Apply the event: return a patch (named list) of state changes.
    transition = function(patient, event, ctx) transition_ascvd(patient, event, ctx),

    # Decide whether to stop simulation after an event.
    stop = function(patient, event, ctx) stop_ascvd(patient, event, ctx),

    # Schema (state variable definitions) and context (parameters/time unit)
    schema = schema,
    ctx = ctx,

    # Derived vars are computed on-demand for snapshots/exports.
    derived_vars = derived_vars_ascvd()
  )
}

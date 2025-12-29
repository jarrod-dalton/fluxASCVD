
#' Bundle for the ASCVD example model
#'
#' @export
bundle_ascvd <- function(schema = schema_ascvd(),
                         ctx = list(time_unit = "unitless")) {

  list(
    init = function(patient, ctx) invisible(NULL),
    propose_events = function(patient, ctx) propose_events_ascvd(patient, ctx),
    transition = function(patient, event, ctx) transition_ascvd(patient, event, ctx),
    stop = function(patient, event, ctx) stop_ascvd(patient, event, ctx),
    schema = schema,
    ctx = ctx,
    derived_vars = derived_vars_ascvd()
  )
}

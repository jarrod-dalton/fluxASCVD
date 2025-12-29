
#' Propose next events for the ASCVD example model
#'
#' The core engine expects a list of "event proposals" where each proposal
#' contains at least:
#'   - time_next (numeric scalar)
#'   - event_type (character scalar)
#'
#' We keep the example deterministic and simple:
#'   - A clinic visit is offered every 1 time unit while the ascvd scope is active.
#'   - If a BMP was ordered, we offer a BMP result event shortly after.
#'   - An ASCVD event is offered later to demonstrate competing event types.
#'
#' @export
propose_events_ascvd <- function(patient, ctx) {
  t <- patient$time()

  # If model_active exists, respect it. Otherwise, assume ascvd is active.
  active <- TRUE
  if ("core__model_active" %in% names(patient$schema)) {
    ma <- patient$state("core__model_active")
    if (is.logical(ma) && !is.null(names(ma)) && "ascvd" %in% names(ma)) {
      active <- isTRUE(ma[["ascvd"]])
    }
  }
  if (!isTRUE(active)) {
    return(list())
  }

  # Always offer a clinic visit at t+1
  props <- list(list(time_next = t + 1, event_type = "clinic_visit", process_id = "clinic"))

  # If BMP ordered and not yet measured, offer bmp at order time + 0.1 (or t+0.1 if order time is in past/NA)
  order_time <- patient$state("bmp_order_time")
  bmp_measured <- patient$state("bmp_measured")
  if (!is.na(order_time) && is.na(bmp_measured)) {
    tt <- max(t + 0.1, order_time + 0.1)
    props[[length(props) + 1]] <- list(time_next = tt, event_type = "bmp", process_id = "bmp")
  }

  # Offer a distant ASCVD event (example only)
  props[[length(props) + 1]] <- list(time_next = t + 2, event_type = "ascvd_event", process_id = "ascvd_event")

  props
}

stop_ascvd <- function(patient, event, ctx) {
  if (event$event_type == "ascvd_event") return(TRUE)
  FALSE
}

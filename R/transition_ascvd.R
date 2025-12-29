transition_ascvd <- function(patient, event, ctx) {
  et <- event$event_type

  if (et == "clinic_visit") {
    # No-show model (simple)
    if (stats::runif(1) < 0.2) return(NULL)

    updates <- list()

    # BP update
    # NOTE: patient$state() returns a ps_state object (list-like). Extract the
    # scalar value before arithmetic.
    sbp0 <- patient$state("sbp")$sbp
    dbp0 <- patient$state("dbp")$dbp
    sbp <- sbp0 + stats::rnorm(1, -5, 10)
    dbp <- dbp0 + stats::rnorm(1, -3, 5)
    updates <- c(updates, list(sbp = sbp, dbp = dbp))

    # HTN intensification
    if (sbp > 130 || dbp > 80) {
      n <- patient$state("n_antihypertensives")$n_antihpertensives
      updates$n_antihypertensives <- min(n + 1, 4)
    }

    # Order labs
    updates$bmp_order_time <- event$time_next
    updates$lipid_order_time <- event$time_next

    return(updates)
  }

  if (et == "bmp_draw") {
    return(list(
      sodium = stats::rnorm(1, 140, 2),
      potassium = stats::rnorm(1, 4.2, 0.3),
      creatinine = stats::rnorm(1, 1.0, 0.1),
      glucose = stats::rnorm(1, 100, 10),
      bmp_order_time = NA_real_
    ))
  }

  if (et == "lipid_draw") {
    return(list(
      ldl = stats::rnorm(1, 100, 20),
      hdl = stats::rnorm(1, 50, 10),
      triglycerides = stats::rnorm(1, 150, 40),
      lipid_order_time = NA_real_
    ))
  }

  if (et == "ascvd_event") {
    # ASCVD event ends active follow-up in this toy model.
    #
    # Important semantic: the simulation may stop due to a *non-death* event
    # (e.g., MI or stroke). In that case, the patient can still be alive, but
    # state is no longer defined after the stop time.
    #
    # If the ASCVD event is a death event, we also set alive = FALSE.
    if (identical(event$ascvd_type, "death")) {
      return(list(ascvd = 1, alive = FALSE))
    }
    return(list(ascvd = 1))
  }

  NULL
}

propose_events_ascvd <- function(patient, ctx) {
  events <- list()

  # Clinic visit proposal
  # patientSimCore's canonical time accessor is patient$last_time
  # (patient$time is not part of the public contract).
  t0 <- patient$last_time
  t_next <- t0 + stats::rgamma(1, shape = 4, rate = 12)
  events$clinic <- list(
    time_next = t_next,
    event_type = "clinic_visit",
    process_id = "clinic"
  )

  # BMP draw if ordered
  bmp_time <- patient$state("bmp_order_time")
  if (!is.na(bmp_time)) {
    events$bmp <- list(
      time_next = bmp_time,
      event_type = "bmp_draw",
      process_id = "bmp"
    )
  }

  # Lipid draw if ordered
  lipid_time <- patient$state("lipid_order_time")
  if (!is.na(lipid_time)) {
    events$lipids <- list(
      time_next = lipid_time,
      event_type = "lipid_draw",
      process_id = "lipids"
    )
  }

  # Terminal ASCVD event
  lambda <- 0.02
  t_ascvd <- t0 + stats::rexp(1, rate = lambda)
  events$ascvd <- list(
    time_next = t_ascvd,
    event_type = "ascvd_event",
    process_id = "ascvd",
    ascvd_type = sample(c("mi", "stroke", "death"), 1)
  )

  events
}

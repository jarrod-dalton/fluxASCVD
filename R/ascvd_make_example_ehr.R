ascvd_make_example_ehr <- function(n_patients = 50, seed = 123) {

  set.seed(seed)

  # Cohort entry dates (index date) spanning ~2 years
  index_date0 <- as.Date("2018-01-01")
  index_date <- index_date0 + sample(0:700, n_patients, replace = TRUE)

  patients <- data.frame(
    patient_id = seq_len(n_patients),
    index_date = index_date,
    sex = sample(c("F", "M"), n_patients, replace = TRUE),
    stringsAsFactors = FALSE
  )

  # Helper: sample observation dates for each patient within follow-up window
  sample_obs_dates <- function(pid, n, max_days = 9 * 365) {
    d0 <- patients$index_date[patients$patient_id == pid]
    d0 + sort(sample(0:max_days, n, replace = FALSE))
  }

  # LABS (LDL/HDL): episodic, irregular. Rounded to integers for presentation.
  labs_list <- lapply(patients$patient_id, function(pid) {
    n <- sample(2:6, 1)
    d <- sample_obs_dates(pid, n, max_days = 8 * 365)

    data.frame(
      patient_id = pid,
      obs_date = d,
      ldl = as.integer(round(pmax(40, rnorm(n, 130, 25)))),
      hdl = as.integer(round(pmax(10, rnorm(n, 50, 10))))
    )
  })
  labs <- do.call(rbind, labs_list)

  # VITALS (SBP/DBP): correlated bivariate normal (specified moments). Rounded to integers.
  # SBP ~ N(130, 7^2), DBP ~ N(86, 4^2), corr = 0.7
  mu_sbp <- 130
  mu_dbp <- 86
  sd_sbp <- 7
  sd_dbp <- 4
  rho <- 0.7

  vitals_list <- lapply(patients$patient_id, function(pid) {
    n <- sample(3:7, 1)  # slightly denser than labs
    d <- sample_obs_dates(pid, n, max_days = 8 * 365)

    z1 <- rnorm(n)
    z2 <- rnorm(n)
    sbp <- mu_sbp + sd_sbp * z1
    dbp <- mu_dbp + sd_dbp * (rho * z1 + sqrt(1 - rho^2) * z2)

    data.frame(
      patient_id = pid,
      obs_date = d,
      sbp = as.integer(round(sbp)),
      dbp = as.integer(round(dbp))
    )
  })
  vitals <- do.call(rbind, vitals_list)

  # CLINICAL EVENTS: ensure enough events to illustrate competing risks
  event_types <- c("office_visit", "hospitalization", "MI", "stroke")
  events_list <- lapply(patients$patient_id, function(pid) {
    # Moderate density: most patients have 1-4 events
    n <- sample(1:4, 1, prob = c(0.30, 0.30, 0.25, 0.15))
    d <- sample_obs_dates(pid, n, max_days = 9 * 365)
    data.frame(
      patient_id = pid,
      event_date = d,
      event = sample(event_types, n, replace = TRUE)
    )
  })
  events <- do.call(rbind, events_list)

  # DEATH: a single record for a subset (competing risk)
  death_ids <- sample(patients$patient_id, size = max(2, floor(0.10 * n_patients)), replace = FALSE)
  death_events <- do.call(rbind, lapply(death_ids, function(pid) {
    d <- patients$index_date[patients$patient_id == pid] + sample(365:(10*365), 1)
    data.frame(patient_id = pid, event_date = d, event = "death")
  }))
  events <- rbind(events, death_events)

  # MEDICATIONS: mix of agents; start dates irregular
  med_types <- c("statin", "ace_inhibitor", "beta_blocker", "aspirin")
  meds_list <- lapply(patients$patient_id, function(pid) {
    n <- sample(1:4, 1, prob = c(0.25, 0.35, 0.25, 0.15))
    d <- sample_obs_dates(pid, n, max_days = 8 * 365)
    data.frame(
      patient_id = pid,
      start_date = d,
      medication = sample(med_types, n, replace = TRUE)
    )
  })
  meds <- do.call(rbind, meds_list)

  # Order tables as typical EHR extracts
  labs <- labs[order(labs$patient_id, labs$obs_date), ]
  vitals <- vitals[order(vitals$patient_id, vitals$obs_date), ]
  events <- events[order(events$patient_id, events$event_date), ]
  meds <- meds[order(meds$patient_id, meds$start_date), ]

  list(
    patients = patients,
    labs = labs,
    vitals = vitals,
    events = events,
    meds = meds
  )
}

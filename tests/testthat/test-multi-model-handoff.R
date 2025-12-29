test_that("namespaced patches support multi-scope handoff without touching single-model workflow", {
  skip_if_not_installed("patientSimCore")

  # Extend the core default schema with a multi-scope model_active and a few
  # model-specific (namespaced) variables.
  schema <- patientSimCore::default_patient_schema()
  schema$model_active <- patientSimCore::model_active_schema_var(
    scopes = c("ascvd", "hospital"),
    default = c(ascvd = TRUE, hospital = FALSE)
  )

  schema$ascvd__ldl            <- list(default = 130)
  schema$ascvd__last_hosp_time <- list(default = NA_real_)

  schema$hospital__admitted     <- list(default = FALSE)
  schema$hospital__ldl_measured <- list(default = NA_real_)
  schema$hospital__discharged   <- list(default = FALSE)

  p <- patientSimCore::new_patient(
    init = list(age = 60, sex = "M"),
    schema = schema
  )

  # A tiny "hospitalization" process that toggles hospital on/off and hands off
  # LDL from hospital -> ascvd on discharge.
  hospital_bundle <- list(
    init_patient = function(patient, ctx) invisible(NULL),

    propose_events = function(patient, ctx, process_ids = NULL, current_proposals = NULL) {
      pid <- "hospital"
      if (!is.null(process_ids) && !(pid %in% process_ids)) return(list())

      s <- patient$as_list(c("hospital__admitted", "hospital__discharged", "hospital__ldl_measured"))
      t0 <- patient$last_time

      if (!isTRUE(s$hospital__admitted)) {
        ev <- list(time_next = 1.0, event_type = "hosp_admit", process_id = pid)
      } else if (isTRUE(s$hospital__admitted) && isFALSE(s$hospital__discharged)) {
        if (is.na(s$hospital__ldl_measured)) {
          ev <- list(time_next = 1.1, event_type = "hosp_ldl", process_id = pid)
        } else {
          ev <- list(time_next = 1.2, event_type = "hosp_discharge", process_id = pid)
        }
      } else {
        # no further events once discharged
        return(list())
      }

      list(hospital = ev)
    },

    transition = function(patient, event, ctx) {
      t_next <- event$time_next

      if (event$event_type == "hosp_admit") {
        list(
          core = list(model_active = c(ascvd = TRUE, hospital = TRUE)),
          hospital = list(admitted = TRUE),
          ascvd = list(last_hosp_time = t_next)
        )
      } else if (event$event_type == "hosp_ldl") {
        list(hospital = list(ldl_measured = 110))
      } else if (event$event_type == "hosp_discharge") {
        ldl_meas <- patient$as_list("hospital__ldl_measured")$hospital__ldl_measured
        list(
          core = list(model_active = c(ascvd = TRUE, hospital = FALSE)),
          hospital = list(discharged = TRUE),
          ascvd = list(ldl = ldl_meas)
        )
      } else {
        stop("unexpected event type")
      }
    },

    stop = function(patient, event, ctx) FALSE,

    refresh_rules = function(patient, last_event, changes, ctx) "ALL"
  )

  # Register the test bundle via a provider (Engine does not accept raw bundles).
  provider <- patientSimCore::PackageProvider$new(
    registry = list(hospital = function(...) hospital_bundle)
  )

  eng <- patientSimCore::Engine$new(
    provider = provider,
    model_spec = list(name = "hospital")
  )

  out <- eng$run(p, max_time = 2.0)
  patient <- out$patient

  s0 <- patient$snapshot_at_time(0.0)
  s1 <- patient$snapshot_at_time(1.0)
  s2 <- patient$snapshot_at_time(1.2)

  expect_true(isTRUE(s0$model_active[["ascvd"]]))
  expect_false(isTRUE(s0$model_active[["hospital"]]))

  expect_true(isTRUE(s1$model_active[["hospital"]]))
  expect_equal(s1$ascvd__last_hosp_time, 1.0)

  expect_false(isTRUE(s2$model_active[["hospital"]]))
  expect_equal(s2$hospital__ldl_measured, 110)
  expect_equal(s2$ascvd__ldl, 110)
})

test_that("namespaced patches support multi-scope handoff without touching single-model workflow", {
  skip_if_not_installed("patientSimCore")

  schema <- patientSimCore::default_patient_schema()
  schema$model_active <- patientSimCore::model_active_schema_var(default = c(ascvd = TRUE, hospital = FALSE))

  schema$ascvd__ldl            <- list(default = 130)
  schema$ascvd__last_hosp_time <- list(default = NA_real_)

  schema$hospital__admitted     <- list(default = FALSE)
  schema$hospital__ldl_measured <- list(default = NA_real_)
  schema$hospital__discharged   <- list(default = FALSE)

  p <- patientSimCore::new_patient(
    init = list(age = 60, sex = "M"),
    schema = schema
  )

  bundle <- list(
    init_patient = function(patient, ctx) invisible(NULL),

    propose_events = function(patient, ctx) {
      s <- patient$as_list(c("hospital__admitted", "hospital__discharged", "hospital__ldl_measured"))
      evs <- list()

      if (!isTRUE(s$hospital__admitted)) {
        evs[[1L]] <- list(time = 1.0, event_type = "hosp_admit")
      } else if (isTRUE(s$hospital__admitted) && isFALSE(s$hospital__discharged)) {
        if (is.na(s$hospital__ldl_measured)) {
          evs[[length(evs) + 1L]] <- list(time = 1.1, event_type = "hosp_ldl")
        }
        evs[[length(evs) + 1L]] <- list(time = 1.2, event_type = "hosp_discharge")
      }

      evs
    },

    transition = function(patient, event, ctx) {
      t <- event$time

      if (event$event_type == "hosp_admit") {
        list(
          core = list(model_active = c(ascvd = TRUE, hospital = TRUE)),
          hospital = list(admitted = TRUE),
          ascvd = list(last_hosp_time = t)
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

    stop = function(patient, event, ctx) FALSE
  )

  eng <- patientSimCore::Engine$new(bundle = bundle, end_time = 2.0)
  out <- eng$run(p)
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

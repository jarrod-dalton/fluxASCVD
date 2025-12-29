test_that("ASCVD smoke: forecast summary_stats runs and returns expected shapes", {
  skip_if_not_installed("patientSimCore")
  skip_if_not_installed("patientSimForecast")

  library(patientSimCore)
  library(patientSimForecast)

  provider <- patientSimCore::PackageProvider$new(
    registry = list(default = patientSimASCVD::ascvd_model_bundle)
  )
  engine <- patientSimCore::Engine$new(
    provider = provider,
    model_spec = list(name = "default")
  )

  schema <- patientSimASCVD::ascvd_schema()

  patient_df <- data.frame(
    age = 62,
    sex = "M",
    sbp = 138,
    dbp = 82,
    ldl = 120,
    hdl = 45,
    triglycerides = 160,
    sodium = 140,
    potassium = 4.2,
    creatinine = 1.0,
    glucose = 98,
    stringsAsFactors = FALSE
  )

  pat <- patientSimCore::new_patient(patient_df, schema = schema)

  fx <- patientSimForecast::forecast(
    engine = engine,
    patients = pat,
    times = c(0, 1, 3, 5),
	  vars = c("sbp", "dbp"),
    S = 10,
    param_sets = list(list()),
    ctx = list(time_unit = "years"),
    backend = "none",
    return = "summary_stats",
    summary_stats = "both",
	  summary_spec = list(event = c("ascvd_event"), start_time = 0)
  )

  expect_true(is.list(fx))
  expect_true(all(c("risk", "state") %in% names(fx)))

  # Risk output should have time column and a numeric risk column
  expect_true(is.data.frame(fx$risk$result))
  expect_true(all(c("time", "risk") %in% names(fx$risk$result)))

  # State output should include the requested vars
  expect_true(is.data.frame(fx$state$result))
  expect_true(all(c("var", "time") %in% names(fx$state$result)))
  expect_true(all(c("sbp", "dbp") %in% unique(fx$state$result$var)))
})

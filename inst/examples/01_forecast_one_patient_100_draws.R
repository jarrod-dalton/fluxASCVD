# Example: Forecast 100 trajectories for one "real" patient and summarize
#
# - Patient input can be a 1-row data.frame (or named list) passed to patientSimCore::new_patient().
# - Summary statistics are computed over simulation runs treated as draws from the posterior predictive.
# - State summaries are conditioned at each time on the model-defined "alive" state (and any follow-up
#   behavior implied by the model's stop logic and snapshot availability).

library(patientSimCore)
library(patientSimForecast)
library(patientSimASCVD)

# Engine: load ASCVD bundle through a registry-based PackageProvider
provider <- patientSimCore::PackageProvider$new(
  registry = list(default = patientSimASCVD::ascvd_model_bundle)
)
engine <- patientSimCore::Engine$new(
  provider = provider,
  model_spec = list(name = "default")
)

# Schema (internal helper; used here for examples)
schema <- patientSimASCVD:::ascvd_schema()

# "Real patient" input (1-row data.frame)
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

pat <- patientSimCore::new_patient(
  init = patient_df,
  schema = schema,
  time0 = 0,
  event_type0 = "init"
)

# Forecast grid
# Keep this small for interactive use; e.g., 3-5 times.
times <- c(0, 1, 5)

# One parameter set (extend to multiple param_sets as needed)
param_sets <- list(list())

# Context for the simulation run
ctx <- list(
  time_unit = "years",
  params = param_sets[[1]]
)

# Run 100 trajectories and return summaries
res <- patientSimForecast::forecast(
  engine = engine,
  patients = pat,
  times = times,
  S = 100,
  param_sets = param_sets,
  ctx = ctx,
  backend = "none",
  return = "summary_stats",
  summary_stats = "both",
  summary_spec = list(
    # risk(): compute risk of event types among the eligible cohort defined at start_time
    event = c("death"),
    start_time = 0
  ),
  vars = c("age", "sex", "sbp", "dbp", "ldl", "hdl", "triglycerides", "ascvd")
)

# res$risk is a ps_risk object (data.frame-like)
# res$state is a state summary (data.frame-like)
print(res$risk)
print(res$state)

# Example: Two parameter sets (equal-weight posterior pooling)
#
# Here we run 50 trajectories under each parameter set (100 total) and summarize.

library(patientSimCore)
library(patientSimForecast)
library(patientSimASCVD)

provider <- patientSimCore::PackageProvider$new(
  registry = list(default = patientSimASCVD::ascvd_model_bundle)
)
engine <- patientSimCore::Engine$new(provider = provider, model_spec = list(name = "default"))

schema <- patientSimASCVD:::ascvd_schema()
pat <- patientSimCore::new_patient(
  init = data.frame(age = 62, sex = "M", sbp = 138, dbp = 82, stringsAsFactors = FALSE),
  schema = schema
)

times <- c(0, 1, 5)

# Two parameter sets (placeholders)
param_sets <- list(
  list(),
  list()
)

# Optional: list-of-ctx where each ctx can carry its own params (overrides param_sets)
ctx_list <- list(
  list(time_unit = "years", params = param_sets[[1]]),
  list(time_unit = "years", params = param_sets[[2]])
)

res <- patientSimForecast::forecast(
  engine = engine,
  patients = pat,
  times = times,
  S = 50,
  param_sets = param_sets,
  ctx = ctx_list,
  backend = "none",
  return = "summary_stats",
  summary_stats = "both",
  summary_spec = list(event = c("death"), start_time = 0),
  vars = c("age", "sex", "sbp", "dbp", "ascvd")
)

print(res$risk)
print(res$state)

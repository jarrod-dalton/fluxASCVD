# Example: Multiple parameter sets for one patient (equal-weight posterior pooling)
#
# Here we run 20 parameter sets with 50 simulations each (1000 total). If you want
# equal weight across parameter sets, keep S the same for each parameter set.
#
# In this v1 pattern, we pass:
# - param_sets = list-of-params (length P)
# - ctx = list-of-ctx (length P), where each ctx may include its own $params

library(patientSimCore)
library(patientSimForecast)
library(patientSimASCVD)

provider <- patientSimCore::PackageProvider$new(
  registry = list(default = patientSimASCVD::ascvd_model_bundle)
)
engine <- patientSimCore::Engine$new(provider = provider, model_spec = list(name = "default"))

schema <- patientSimASCVD:::ascvd_schema()
patient_df <- data.frame(age = 62, sex = "M", sbp = 138, dbp = 82, stringsAsFactors = FALSE)
pat <- patientSimCore::new_patient(init = patient_df, schema = schema)

times <- c(0, 1, 5)

# Construct P parameter sets (placeholder lists here)
P <- 20
param_sets <- replicate(P, list(), simplify = FALSE)

# Per-parameter-set ctx (length P)
ctx_list <- lapply(param_sets, function(p) list(time_unit = "years", params = p))

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
  vars = c("sbp", "dbp", "ascvd")
)

print(res$risk)
print(res$state)

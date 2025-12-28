# ------------------------------------------------------------------------------
# Multi-model handoff toy example (hospital -> ascvd)
#
# This is an *illustrative* example of how to compose two model "scopes" over a
# single canonical patient time axis using namespaced state variables and an
# explicit handoff payload.
#
# Notes:
# - Uses patientSimCore namespaced patch support: list(core=list(...), ascvd=list(...), hospital=list(...))
# - Namespaced state variables are stored as "<namespace>__<var>" in the schema.
# - Single-model users do NOT need any of this.
# ------------------------------------------------------------------------------

library(patientSimCore)

# ---- schema: start from ASCVD's usual core schema, then add scoped vars ----
schema <- patientSimCore::default_patient_schema()

schema$model_active <- patientSimCore::model_active_schema_var(default = c(ascvd = TRUE, hospital = FALSE))

# ASCVD scoped vars (toy)
schema$ascvd__ldl            <- list(default = 130)
schema$ascvd__last_hosp_time <- list(default = NA_real_)

# Hospital scoped vars (toy)
schema$hospital__admitted      <- list(default = FALSE)
schema$hospital__ldl_measured  <- list(default = NA_real_)
schema$hospital__discharged    <- list(default = FALSE)

# ---- patient ----
p <- patientSimCore::new_patient(
  init = list(age = 60, sex = "M"),
  schema = schema
)

# ---- a tiny "two-scope" bundle ----
bundle <- list(
  init_patient = function(patient, ctx) invisible(NULL),

  propose_events = function(patient, ctx) {
    s <- patient$as_list(c("hospital__admitted", "hospital__discharged"))
    t <- patient$last_time

    evs <- list()

    if (!isTRUE(s$hospital__admitted)) {
      evs[[length(evs) + 1L]] <- list(time = 1.0, event_type = "hosp_admit")
    } else if (isTRUE(s$hospital__admitted) && isFALSE(s$hospital__discharged)) {
      if (is.na(patient$as_list("hospital__ldl_measured")$hospital__ldl_measured)) {
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
      list(
        hospital = list(ldl_measured = 110)
      )
    } else if (event$event_type == "hosp_discharge") {
      # explicit payload: pass measured LDL into ASCVD latent LDL
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
res <- eng$run(p)

# ---- inspect snapshots ----
snap0 <- res$patient$snapshot_at_time(0.0)
snapA <- res$patient$snapshot_at_time(1.0)
snapD <- res$patient$snapshot_at_time(1.2)

print(snap0[c("model_active", "ascvd__ldl", "hospital__admitted")])
print(snapA[c("model_active", "ascvd__last_hosp_time", "hospital__admitted")])
print(snapD[c("model_active", "ascvd__ldl", "hospital__discharged")])

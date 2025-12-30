schema_ascvd <- function(scopes = c("ascvd", "hospital"),
                         model_active_default = c(ascvd = TRUE, hospital = FALSE)) {

# Educational schema builder for the ASCVD example model.
#
# Key idea: patientSimCore stores patient state as a named list of "schema vars".
# Each schema var declares:
#   - type (numeric/int/logical/character/list)
#   - default value
#   - description (used for documentation / introspection)
#
# This package demonstrates how a model package can:
#   1) start from the core default schema (demographics + time)
#   2) add model-specific state (e.g., SBP, LDL)
#   3) optionally add cross-model bookkeeping (model_active) to support handoffs.


  base <- patientSimCore::default_patient_schema()

  extra <- list(
    # Multi-model coordination lives at the top level. The core scope is
    # special-cased by patientSimCore::flatten_namespaced_patches() so
    # list(core = list(model_active = ...)) updates this variable.
    model_active = patientSimCore::model_active_schema_var(
      default = model_active_default,
      desc = "Which models are active for this patient"
    ),

    # ASCVD state (kept unscoped for this example model)
    last_clinic_time    = patientSimCore::schema_var(NA_real_, desc = "Last clinic visit time"),
    sbp                 = patientSimCore::schema_var(120, desc = "Systolic BP"),
    dbp                 = patientSimCore::schema_var(80, desc = "Diastolic BP"),
    bmp_order_time      = patientSimCore::schema_var(NA_real_, desc = "Time BMP panel ordered"),
    bmp_measured_time   = patientSimCore::schema_var(NA_real_, desc = "Time BMP panel measured"),
    ldl                 = patientSimCore::schema_var(110, desc = "LDL cholesterol"),
    ascvd_event         = patientSimCore::schema_var(FALSE, desc = "Whether ASCVD event occurred"),

    # Additional labs used in the smoke tests (defaults are NA)
    hdl           = patientSimCore::schema_var(NA_real_, desc = "HDL cholesterol"),
    triglycerides = patientSimCore::schema_var(NA_real_, desc = "Triglycerides"),
    sodium        = patientSimCore::schema_var(NA_real_, desc = "Sodium"),
    potassium     = patientSimCore::schema_var(NA_real_, desc = "Potassium"),
    creatinine    = patientSimCore::schema_var(NA_real_, desc = "Creatinine"),
    glucose       = patientSimCore::schema_var(NA_real_, desc = "Glucose")
  )

  c(base, extra)
}


#' ASCVD example schema
#'
#' Provides a minimal schema for the patientSimASCVD example package.
#'
#' @export
schema_ascvd <- function(scopes = c("ascvd", "hospital"),
                        model_active_default = c(ascvd = TRUE, hospital = FALSE)) {

  base <- patientSimCore::default_patient_schema()

  # Multi-model activation lives in the "core" scope so that model packages can
  # coordinate handoffs via namespaced patches like list(core = list(model_active = ...)).
  base <- patientSimCore::schema_add(base, list(
    core__model_active = patientSimCore::model_active_schema_var(
      scopes = scopes,
      default = model_active_default
    )
  ))

  # Add ASCVD-specific state vars (kept intentionally small and generic).
  ascvd_vars <- list(
    sbp = list(
      default = 120,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && is.finite(x)
    ),
    dbp = list(
      default = 80,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && is.finite(x)
    ),
    ldl = list(
      default = NA_real_,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && (is.na(x) || is.finite(x))
    ),
    bmp_order_time = list(
      default = NA_real_,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && (is.na(x) || is.finite(x))
    ),
    bmp_measured = list(
      default = NA_real_,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && (is.na(x) || is.finite(x))
    ),
    last_clinic_time = list(
      default = 0,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && is.finite(x) && x >= 0
    ),
    last_hosp_time = list(
      default = NA_real_,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && (is.na(x) || (is.finite(x) && x >= 0))
    )
  )

  patientSimCore::schema_add(base, ascvd_vars)
}

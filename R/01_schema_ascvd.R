# patientSimASCVD
#
# 01_schema_ascvd.R
#
# This package is a pedagogical, worked example of a model that plugs into
# patientSimCore (engine + state truth) and patientSimForecast (summaries).
#
# Design intent for the example model:
# - Keep the surface area small.
# - Demonstrate strict schema defaults.
# - Demonstrate an event-driven loop with:
#     * a recurring "clinic" process (state updates)
#     * a one-time "mi" event that stops follow-up without implying death
#
# The naming "ASCVD" is historical. The model below is intentionally toy-sized.

ascvd_schema <- function() {
  # Start with core defaults (alive, etc.).
  schema <- patientSimCore::default_patient_schema()

  # Helper to define a variable in one place, using the patientSimCore schema contract.
  add_var <- function(name, default, type = c("continuous", "binary", "categorical", "ordinal", "count"),
                      levels = NULL, blocks = NULL, validate = NULL, coerce = NULL) {
    type <- match.arg(type)
    if (is.null(coerce)) {
      coerce <- switch(
        type,
        continuous = as.numeric,
        count = as.integer,
        binary = as.logical,
        categorical = as.character,
        ordinal = as.character
      )
    }
    if (is.null(validate)) {
      validate <- function(x) length(x) == 1L && !is.na(x)
    }
    schema[[name]] <<- list(
      type = type,
      levels = levels,
      default = default,
      coerce = coerce,
      validate = validate,
      blocks = blocks
    )
  }

  # Demographics.
  add_var("age", 55, type = "continuous", blocks = "demo",
          validate = function(x) length(x) == 1L && is.finite(x) && x >= 0)
  add_var("sex", "M", type = "categorical", levels = c("F", "M"), blocks = "demo")

  # Vital signs.
  add_var("sbp", 130, type = "continuous", blocks = "vitals")
  add_var("dbp", 80,  type = "continuous", blocks = "vitals")

  # A simple state marker to show how models can carry latent state.
  # (e.g., this could represent treatment intensification after MI).
  add_var("phase", "baseline", type = "categorical", levels = c("baseline", "post_mi"), blocks = "model")

  schema
}

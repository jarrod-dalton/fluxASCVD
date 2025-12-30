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

  # Helper to define a variable in one place.
  add_var <- function(name, default, type = c("numeric", "logical", "character"),
                      blocks = NULL, required = FALSE) {
    type <- match.arg(type)
    schema[[name]] <<- list(
      default = default,
      type = type,
      blocks = blocks,
      required = required
    )
  }

  # Demographics.
  add_var("age", 55, type = "numeric", blocks = "demo", required = TRUE)
  add_var("sex", "M", type = "character", blocks = "demo", required = TRUE)

  # Vital signs.
  add_var("sbp", 130, type = "numeric", blocks = "vitals", required = TRUE)
  add_var("dbp", 80,  type = "numeric", blocks = "vitals", required = TRUE)

  # A simple state marker to show how models can carry latent state.
  # (e.g., this could represent treatment intensification after MI).
  add_var("phase", "baseline", type = "character", blocks = "model")

  schema
}

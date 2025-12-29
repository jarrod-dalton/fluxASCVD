# ------------------------------------------------------------------------------
# ASCVD patient schema
#
# Defines required core state, panels (blocks), treatments, and lab order state.
# Age and sex are required at patient instantiation.
# ------------------------------------------------------------------------------
ascvd_schema <- function() {
  schema <- patientSimCore::default_patient_schema()

  # Core demographics are required for ASCVD.
  schema$age$required <- TRUE
  schema$sex$required <- TRUE

  # Helper: add a schema entry only if it doesn't already exist.
  add_if_missing <- function(nm, entry) {
    if (is.null(schema[[nm]])) schema[[nm]] <<- entry
    invisible(NULL)
  }

  # ASCVD-specific clinical state. Keep these out of Core.
  add_if_missing(
    "sbp",
    list(
      default = 120,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && is.finite(x) && x > 0,
      blocks = "bp"
    )
  )
  add_if_missing(
    "dbp",
    list(
      default = 80,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && is.finite(x) && x > 0,
      blocks = "bp"
    )
  )

  add_if_missing(
    "sodium",
    list(
      default = 140,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && is.finite(x),
      blocks = "bmp"
    )
  )
  add_if_missing(
    "potassium",
    list(
      default = 4.2,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && is.finite(x),
      blocks = "bmp"
    )
  )
  add_if_missing(
    "creatinine",
    list(
      default = 1.0,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && is.finite(x) && x >= 0,
      blocks = "bmp"
    )
  )
  add_if_missing(
    "glucose",
    list(
      default = 95,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && is.finite(x) && x >= 0,
      blocks = "bmp"
    )
  )

  add_if_missing(
    "ldl",
    list(
      default = 110,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && is.finite(x) && x >= 0,
      blocks = "lipids"
    )
  )
  add_if_missing(
    "hdl",
    list(
      default = 50,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && is.finite(x) && x >= 0,
      blocks = "lipids"
    )
  )
  add_if_missing(
    "triglycerides",
    list(
      default = 150,
      coerce = as.numeric,
      validate = function(x) length(x) == 1L && is.finite(x) && x >= 0,
      blocks = "lipids"
    )
  )

  add_if_missing("n_antihypertensives", list(default = 0, blocks = "tx_htn"))
  add_if_missing("statin_intensity", list(default = "none", blocks = "tx_lipid"))
  add_if_missing("bmp_order_time", list(default = NA_real_))
  add_if_missing("lipid_order_time", list(default = NA_real_))
  add_if_missing("ascvd", list(default = 0))

  # If the variables existed upstream (e.g., from a larger composed schema),
  # ensure blocks are set as expected.
  schema$sbp$blocks <- unique(c(schema$sbp$blocks, "bp"))
  schema$dbp$blocks <- unique(c(schema$dbp$blocks, "bp"))
  schema$sodium$blocks <- unique(c(schema$sodium$blocks, "bmp"))
  schema$potassium$blocks <- unique(c(schema$potassium$blocks, "bmp"))
  schema$creatinine$blocks <- unique(c(schema$creatinine$blocks, "bmp"))
  schema$glucose$blocks <- unique(c(schema$glucose$blocks, "bmp"))
  schema$ldl$blocks <- unique(c(schema$ldl$blocks, "lipids"))
  schema$hdl$blocks <- unique(c(schema$hdl$blocks, "lipids"))
  schema$triglycerides$blocks <- unique(c(schema$triglycerides$blocks, "lipids"))

  schema
}

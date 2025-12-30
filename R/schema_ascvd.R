# ------------------------------------------------------------------------------
# ASCVD patient schema
#
# Defines required core state, panels (blocks), treatments, and lab order state.
# Age and sex are required at patient instantiation.
# ------------------------------------------------------------------------------
ascvd_schema <- function() {
  schema <- patientSimCore::default_patient_schema()

  # Minimal validators used for ASCVD-specific variables.
  # We allow NA for most clinical fields (they can be unmeasured), but keep
  # them scalar and type-coercible.
  .v_num_na <- function(x) length(x) == 1L && (is.na(x) || is.finite(x))
  .v_int_na <- function(x) length(x) == 1L && (is.na(x) || (is.finite(x) && x == as.integer(x)))

  schema$age$required <- TRUE

  # Demographics (ASCVD layer adds these to the Core schema).
  schema$sex <- list(
    default  = NA_character_,
    coerce   = as.character,
    validate = function(x) length(x) == 1L && (is.na(x) || x %in% c("M", "F"))
  )
  schema$sex$required <- TRUE

  # Blood pressure
  schema$sbp <- list(default = NA_real_, coerce = as.numeric, validate = .v_num_na, blocks = "bp")
  schema$dbp <- list(default = NA_real_, coerce = as.numeric, validate = .v_num_na, blocks = "bp")

  # Basic metabolic panel
  schema$sodium     <- list(default = NA_real_, coerce = as.numeric, validate = .v_num_na, blocks = "bmp")
  schema$potassium  <- list(default = NA_real_, coerce = as.numeric, validate = .v_num_na, blocks = "bmp")
  schema$creatinine <- list(default = NA_real_, coerce = as.numeric, validate = .v_num_na, blocks = "bmp")
  schema$glucose    <- list(default = NA_real_, coerce = as.numeric, validate = .v_num_na, blocks = "bmp")

  # Lipids
  schema$ldl           <- list(default = NA_real_, coerce = as.numeric, validate = .v_num_na, blocks = "lipids")
  schema$hdl           <- list(default = NA_real_, coerce = as.numeric, validate = .v_num_na, blocks = "lipids")
  schema$triglycerides <- list(default = NA_real_, coerce = as.numeric, validate = .v_num_na, blocks = "lipids")

  # Treatments
  schema$n_antihypertensives <- list(
    default  = 0L,
    coerce   = as.integer,
    validate = .v_int_na,
    blocks   = "tx_htn"
  )
  schema$statin_intensity <- list(
    default  = "none",
    coerce   = as.character,
    validate = function(x) length(x) == 1L && !is.na(x),
    blocks   = "tx_lipid"
  )

  schema$bmp_order_time   <- list(default = NA_real_, coerce = as.numeric, validate = .v_num_na)
  schema$lipid_order_time <- list(default = NA_real_, coerce = as.numeric, validate = .v_num_na)

  schema$ascvd <- list(default = 0L, coerce = as.integer, validate = .v_int_na)

  schema
}

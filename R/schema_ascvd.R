# ------------------------------------------------------------------------------
# ASCVD patient schema
#
# Defines required core state, panels (blocks), treatments, and lab order state.
# Age and sex are required at patient instantiation.
# ------------------------------------------------------------------------------
ascvd_schema <- function() {
  schema <- patientSimCore::default_patient_schema()

  schema$age$required <- TRUE
  schema$sex$required <- TRUE

  schema$sbp$blocks <- "bp"
  schema$dbp$blocks <- "bp"

  schema$sodium$blocks <- "bmp"
  schema$potassium$blocks <- "bmp"
  schema$creatinine$blocks <- "bmp"
  schema$glucose$blocks <- "bmp"

  schema$ldl$blocks <- "lipids"
  schema$hdl$blocks <- "lipids"
  schema$triglycerides$blocks <- "lipids"

  schema$n_antihypertensives <- list(default = 0, blocks = "tx_htn")
  schema$statin_intensity <- list(default = "none", blocks = "tx_lipid")

  schema$bmp_order_time <- list(default = NA_real_)
  schema$lipid_order_time <- list(default = NA_real_)

  schema$ascvd <- list(default = 0)

  schema
}

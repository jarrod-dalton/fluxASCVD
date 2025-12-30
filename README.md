# patientSimASCVD

A small, pedagogical disease/process model designed to work with:

- **patientSimCore** (truth generation: state, time, events)
- **patientSimForecast** (summaries: risk, survival, state trajectories)

Despite the name, the current model is intentionally toy-sized. Its purpose is to demonstrate the **model-package pattern** (schema → derived vars → propose events → transition → stop → bundle) with a worked example that stays compatible with the current Core + Forecast APIs.

## What this example does

- Adds a few state variables (`age`, `sex`, `sbp`, `dbp`, `phase`) to the core schema.
- Proposes two processes:
  - `clinic`: recurring clinic visits that update blood pressure
  - `ascvd`: a one-time `mi` event at a fixed time
- Stops follow-up at `mi` **without implying death** (alive stays `TRUE`, but later times are undefined).

## File walkthrough

The files in `R/` are ordered like `patientSimModelTemplate`:

1. `01_schema_ascvd.R`
2. `02_derived_vars_ascvd.R`
3. `03_propose_events_ascvd.R`
4. `04_transition_ascvd.R`
5. `05_stop_ascvd.R`
6. `07_bundle_ascvd.R`


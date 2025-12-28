# patientSimASCVD

`patientSimASCVD` is a pedagogical ASCVD care trajectory model built on
top of `patientSimCore`. It demonstrates how to encode clinic visits,
no-shows, treatments, labs ordered at visits, and terminal ASCVD events
using an event-driven simulation architecture.

This package is intended for teaching, collaboration, and methods
development. Statistical models are placeholders and can be replaced
by ML models without changing the simulation contract.

## Multi-model composition (optional)

`patientSimASCVD` is designed to be used as a *single* disease model package. If your application
requires composing ASCVD with other episodic models (e.g., hospitalization), follow the conventions
documented in `patientSimModelTemplate`:

- namespaced state (e.g., `ascvd$ldl` vs `hospital$ldl_measured`)
- per-model scope flags (e.g., `core$model_active`)
- explicit handoff payloads at admission/discharge boundaries

See `patientSimModelTemplate/docs/MULTI_MODEL_COMPOSITION.md`.


# Modeling ASCVD Care Trajectories with `patientSimASCVD`
## A clinician-facing guide to patient-level simulation

This vignette is for clinicians and clinician–scientists (MD, MD/PhD) collaborating with data scientists to build patient-level simulation models of ASCVD care. It explains how clinical logic is translated into an event-driven simulation, what assumptions are being made, and how clinicians can productively guide those assumptions.

You do not need to write R code to use this framework well. You do need to be willing to say, out loud and specifically, what “care” looks like over time for the patients you care about, and where the model is allowed to be crude versus where it must be faithful.

## What the model is trying to represent

`patientSimASCVD` is designed to simulate *care trajectories*, not physiology in isolation. The emphasis is on how patients interact with the health system, what gets measured, how treatments change in response to those measurements, and how these evolving measurements and treatments relate to the risk of major ASCVD events.

That is a different goal than building a static risk score. A risk score is typically a snapshot: given values today, estimate risk over a horizon. A care-trajectory simulator is a storyline: it needs to describe how today becomes tomorrow. That storyline includes missed appointments, delayed labs, decision thresholds, treatment inertia, and the messy reality that “guidelines” are filtered through clinic capacity, patient preferences, and time.

This package is a pedagogical model. Its statistical “innards” are intentionally simple placeholders so that teams can focus on structure, assumptions, and collaboration. In later iterations, those placeholders can be replaced with ML models without changing the simulation architecture.

## Why an event-driven model fits clinical reality

Clinical care does not unfold in evenly spaced time steps. Patients are seen when they are seen. Labs are ordered during encounters, drawn later (or never), and results return at irregular times. Medications are started or intensified at decision points, not continuously. Acute events can occur between routine follow-ups.

An event-driven simulation mirrors this. Time advances from one clinically meaningful event to the next. The patient state changes only when an event occurs. Multiple “clocks” can run at once—visit scheduling, lab monitoring, and ASCVD risk progression—while still sharing one global time axis.

This typically matches how clinicians think: a patient’s trajectory is a series of episodes and decisions, not a grid of days.

## What the patient state includes

At any point in simulated time, a patient has a state: what the model “knows” about them and what will influence what happens next.

In this ASCVD example, the core state includes age (in years) and sex. These are required at patient instantiation. The model is designed to fail fast if these are missing, because nearly every downstream component depends on them.

Blood pressure is represented as systolic and diastolic values (`sbp`, `dbp`) that are updated jointly to preserve correlation. Laboratory measurements are organized into clinically familiar panels: a basic metabolic panel (BMP) and a lipid panel. The lipid panel is especially important because it interacts tightly with statin treatment intensity.

Treatments are represented with deliberately coarse but clinically meaningful state variables. Antihypertensive therapy is encoded as the number of agents (`n_antihypertensives`), capped at 4 to represent “4+.” Statin therapy is encoded as an ordered category (`statin_intensity`: none, moderate, high). These representations are not meant to encode specific drug classes; they are meant to capture treatment burden and intensity as drivers of downstream measurements and risk.

Finally, the model includes operational state that matters to care delivery: lab orders. For example, `bmp_order_time` indicates that a BMP has been ordered but not yet drawn. This is not a derived quantity; it is an operational commitment that should influence future events.

A terminal indicator (`ascvd`) records whether the patient has experienced a composite ASCVD event. Once that event occurs, the simulation stops.

## What is intentionally not stored as core state

Some quantities are intentionally derived rather than stored. In this model, the number of no-shows is derived from the event history rather than stored as a mutable counter. This prevents subtle bookkeeping errors (such as resetting counts after a visit) and keeps the model honest: if you want to define “no-shows,” you must define what counts as a no-show and then derive it consistently.

Similarly, “BP controlled” flags, risk proxies, and other reporting variables are derived. This makes it easier to adjust definitions without rewriting history.

## Visits, scheduling noise, and no-shows

The model schedules clinic visits at irregular intervals (in years), with random noise around the cadence. This is a practical compromise: it avoids the unrealistic rigidity of fixed-interval follow-up, while still permitting tractable modeling.

At each scheduled visit, the model determines whether the patient attends. Attendance is probabilistic and may depend on patient characteristics, prior no-show history, and treatment burden. In this pedagogical model, no-show logic is explicit and replaceable: teams can start simple and later fit a no-show model from data.

A critical design choice here is that a no-show causes *no updates* to core state. No labs are drawn. No medications are adjusted. No new measurements are obtained. The missed visit is recorded as an event, but the patient’s state remains unchanged. Clinically, this reflects the fact that many downstream consequences of missed care arise precisely because nothing happens.

## Labs only happen when ordered at attended visits

One of the easiest ways for a simulation to lose clinical credibility is to make labs appear on a calendar independent of care. In real practice, lab measurement is an action: someone orders it.

In this model, BMP and lipid panels are only drawn if they have been ordered at an attended clinic visit. The ordering decision can be rule-based (“BMP annually if due”) or more nuanced. Once ordered, the lab draw occurs later as its own event. When the draw occurs, the corresponding panel state is updated and the order flag is cleared.

This ordering–draw sequence aligns with clinical workflows and also forces the team to be explicit about what “monitoring” means in their setting.

## BP measurement and antihypertensive intensification

At an attended clinic visit, BP is measured and the BP state is updated. The model updates SBP and DBP jointly, with measurement noise. Antihypertensive burden modifies expected BP: higher treatment intensity should, on average, reduce BP.

The pedagogical treatment decision rule is intentionally current and recognizable. Antihypertensive therapy is intensified when SBP exceeds 130 or DBP exceeds 80. The escalation is ordinal and capped at 4+ agents. In a realistic model, there is treatment inertia: not every visit leads to intensification even when thresholds are exceeded. In this pedagogical scaffold, inertia can be represented probabilistically and later replaced with an ML decision model.

Clinically, the important point is that the *decision threshold and the inertia assumptions are visible* and therefore discussable.

## Lipids and statin intensity

Lipid levels update only when a lipid panel is drawn. Statin intensity is adjusted at attended clinic visits, based on available lipid information and a risk proxy. Statin intensity is treated as an ordered category: none < moderate < high.

This abstraction is deliberate. It captures the concept of treatment intensity and its downstream effects without forcing early commitment to drug classes, doses, or adherence modeling. Those details can be added later if needed, but the first-order clinical logic can be represented now.

## Terminal composite ASCVD events

ASCVD events are modeled as a terminal process operating on the same global timeline. At any moment, the patient has a hazard of experiencing a composite event. The hazard depends on patient state (age, BP, lipids, treatment intensity) and can be implemented as a simple log-linear model initially.

When an ASCVD event occurs, it is classified as MI, stroke, or all-cause death. The event is recorded and the simulation stops immediately. This aligns with common composite endpoints used in the literature and provides a clear terminal condition for trajectories.

## How to interpret outputs

The primary output of this modeling approach is a patient timeline: a sequence of events with associated times, state changes, and treatment adjustments. Clinically, this is often easier to interpret than a dense table of time-indexed values. You can see missed care, delayed monitoring, treatment escalation, and eventual outcomes as a narrative.

When you interpret results from this model, remember what it is and is not claiming. It encodes assumptions about care processes, patient behavior, and how measurements relate to risk. It does not automatically provide causal effects. If you want causal claims, those must be supported by explicit assumptions and validation work.

## The clinician’s role in model development

Clinicians contribute most by shaping the model’s clinical structure. You can define realistic event types, identify implausible trajectories, and clarify what should or should not change at an event.

When clinicians say things like “we wouldn’t order lipids there,” “patients like this often miss follow-up,” or “we rarely go from zero meds to triple therapy in one visit,” they are providing information the model cannot invent. This is often the difference between a technically impressive model and a clinically credible one.

## Looking ahead

This vignette focuses on representation: how care is encoded. The natural next layer is validation: calibration to observed distributions, dynamic forecasting performance, and sensitivity to assumptions about no-shows and treatment inertia. Those tasks are easier when the core structure is explicit.

The intention of `patientSimASCVD` is to provide a shared language for that interdisciplinary work.

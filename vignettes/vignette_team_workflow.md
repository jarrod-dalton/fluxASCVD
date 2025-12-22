# Team Workflow for Building Patient-Level Simulation Models (Meeting Guide)

This document is meant to be used live in team meetings. It is intentionally concise and operational. The assumption is that team members have already reviewed the role-based vignettes: one for the data scientist implementing the model and one for clinicians shaping the clinical logic.

The goal here is not to debate every parameter. The goal is to reach shared clarity on: what we are modeling, what we are assuming, and what we will validate.

## 1) Define the purpose and scope in one paragraph

Start the meeting by agreeing on a single paragraph that answers:

What population is being represented, what decisions will the model inform, and what outcomes are in scope?

If the team cannot write this paragraph without caveats, the model will drift. Keep it specific. You can always broaden later.

## 2) Agree on the time horizon and time unit

For `patientSimASCVD`, the global time axis is in years. Decide the follow-up horizon (e.g., 5 years, 10 years). Confirm what “time zero” represents (baseline clinic entry, index diagnosis, post-discharge, etc.).

This seems trivial until it isn’t. Many disagreements later are actually disagreements about what “baseline” means.

## 3) Enumerate the event types

Write the event types on the board. For the pedagogical ASCVD model, start with:

Clinic visit, no-show, BMP draw, lipid draw, ASCVD event (MI, stroke, death).

Then ask: what did we miss that would change decisions or risk in a clinically meaningful way? If the answer is “nothing critical,” keep the list short.

## 4) Define the state variables (what the model remembers)

Decide what must be carried forward because it influences the future. In the pedagogical ASCVD model this includes age, sex, SBP/DBP, BMP variables, lipids, antihypertensive count, statin intensity, and lab order state.

Do not overfit state early. If a variable does not influence future events, it may belong in a derived layer or an observation table rather than state.

## 5) Define blocks (panels) and treatments

Clinicians should define the panels as they are used in practice, not as they appear in a dataset. BP, BMP, and lipids are a good starting point.

Treatments should be encoded in a way the team can reason about. In this model: number of antihypertensives (0–4+) and statin intensity (none/moderate/high). Confirm that these are sufficient for the questions you want to ask.

## 6) Decide how care is scheduled

Agree on a visit cadence distribution with jitter. Then define the no-show logic. Start simple. The important thing is to be explicit about whether no-show probability changes with history, burden, or patient characteristics.

Also decide whether labs happen independently or only when ordered. For this model, labs are ordered at attended visits. This is often the point where clinicians will push back if the model is too “calendar-driven.” Keep it encounter-driven.

## 7) Define decision rules at visits (treatments, orders)

Write down the decision triggers in words before coding them.

For hypertension: intensify if SBP > 130 or DBP > 80. Decide whether there is inertia (probabilistic escalation) and what caps exist (4+).

For statins: decide which information triggers escalation (LDL, risk proxy) and what inertia looks like.

For lab orders: decide when BMP and lipids are ordered. Often this is “if due” based on the last measurement time.

## 8) Run a few patient stories and do face-validity review

Before cohort runs, generate a handful of patient trajectories and review the timelines together. Ask clinicians to narrate the timeline and identify what looks wrong.

This step is not optional. It is the fastest way to surface broken assumptions.

## 9) Define validation targets before calibration

Agree on what will be checked against data. Examples:

Visit frequency distribution, no-show rate and persistence, distributions of SBP and LDL at visits, treatment intensification frequencies, time-to-event distribution for composite ASCVD events.

Write these targets down. If they are not written down, validation becomes vibes.

## 10) Assign ownership and next actions

End every meeting with: who is implementing what, what will be reviewed next, and what artifacts will be brought to the next meeting (plots, trajectory examples, calibration tables).

The model improves through iteration, not through single grand designs.

# sprint-2.6

context: root
status: CONVERGED
goal: owner selector invalid-state repair matrix and operator diagnostics refinement

## mission
owner selector invalid-state repair matrix and operator diagnostics refinement

## result
- owner selector diagnostics now distinguish missing, empty, off, target-missing and target-invalid states explicitly
- owner current now exposes runtime link, repair action and repair hint
- owner selector now exposes a canonical repair matrix readable by the operator
- runtime stale and runtime diverged situations are now diagnosed separately
- boot now displays selector mode, runtime relationship and repair hint
- recover remains deterministic and now repairs more invalid selector situations explicitly
- owner log remains active and now records richer state-transition details
- E2E coverage now includes empty selector, missing target, invalid target and diverged runtime cases

## artifacts
- /home/kao/bin/kao-owner
- /home/kao/bin/kao-boot
- /home/kao/tests/e2e/scenarios/boot_check.sh
- /home/kao/tests/e2e/scenarios/operator_flow.sh
- /home/kao/state/sprints/sprint-2.6.md

## expected-validation
- kao owner current shows selector mode, runtime link, repair action and repair hint
- kao owner selector shows a canonical repair matrix
- boot shows selector mode and repair hint
- recover repairs empty, missing-target and invalid-target selector states deterministically
- active valid selector with diverged runtime is diagnosed as REALIGN_RUNTIME
- full E2E passes with score=100 warn=0 errors=0

## next-entry-point
Sprint 2.7 — Owner selector policy hardening and canonical admin ergonomics

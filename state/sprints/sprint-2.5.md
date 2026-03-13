# sprint-2.5

context: root
status: CONVERGED
goal: owner selector recovery and canonical deactivation workflow

## mission
owner selector recovery and canonical deactivation workflow

## result
- canonical owner selector deactivation command added
- canonical owner selector recovery command added
- owner activation command made explicit with activate while preserving use alias compatibility
- owner selector states now distinguish ABSENT, DEACTIVATED and ACTIVE explicitly
- runtime owner cache rebuild is now part of activation and recovery workflow
- owner boot rendering now exposes selector state, runtime cache state and explicit source policy
- retained runtime visibility is preserved when selector is intentionally deactivated
- owner operator log introduced at /home/kao/state/logs/owner.log
- E2E coverage extended for activate, deactivate, recover, retained runtime and owner log events

## artifacts
- /home/kao/bin/kao-owner
- /home/kao/bin/kao-boot
- /home/kao/tests/e2e/scenarios/boot_check.sh
- /home/kao/tests/e2e/scenarios/operator_flow.sh
- /home/kao/state/sprints/sprint-2.5.md

## expected-validation
- kao owner activate <preset> activates selector and rebuilds runtime owner env
- kao owner deactivate writes an explicit OFF selector state
- kao owner recover repairs selector state deterministically using first valid preset when available
- boot displays selector state and runtime cache state explicitly
- owner log records activate, deactivate and recover events
- full E2E passes with score=100 warn=0 errors=0

## next-entry-point
Sprint 2.6 — Owner selector invalid-state repair matrix and operator diagnostics refinement

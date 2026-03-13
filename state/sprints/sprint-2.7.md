# sprint-2.7

context: root
status: INTEGRATED
goal: owner selector policy hardening and canonical admin ergonomics

## mission
owner selector policy hardening and canonical admin ergonomics

## result
- owner admin actions now distinguish success, noop, refused, and repair policy states
- activate now returns noop when the requested preset is already active and aligned
- deactivate now returns noop when the selector is already off
- recover now returns noop when no repair is needed and repair when state realignment is performed
- inspect now refuses missing or invalid presets explicitly
- create now refuses duplicate preset creation explicitly
- canonical admin outputs now expose a shared policy block across create, inspect, edit, activate, deactivate, and recover
- operator flow and boot E2E coverage now validate stricter admin policy semantics

## artifacts
- /home/kao/bin/kao-owner
- /home/kao/tests/e2e/scenarios/operator_flow.sh
- /home/kao/tests/e2e/scenarios/boot_check.sh
- /home/kao/state/sprints/sprint-2.7.md

## expected-validation
- owner activate <active-preset> returns policy state NOOP
- owner deactivate on selector OFF returns policy state NOOP
- owner recover on aligned state returns policy state NOOP
- owner inspect missing returns policy state REFUSED
- owner create existing returns policy state REFUSED
- current and selector remain readable and E2E-compatible

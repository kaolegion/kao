# sprint-2.1

context: root
status: CONVERGED
goal: owner profile management command and preset lifecycle ergonomics

## mission
owner profile management command and preset lifecycle ergonomics

## result
- canonical owner profile management command now exists at /home/kao/bin/kao-owner
- canonical operator entrypoint now supports kao owner ...
- owner command now lists available presets with validity state
- owner command now exposes the currently active selector state explicitly
- owner command now activates a preset canonically through /home/kao/config/owner.profile
- owner command now validates preset existence before activation
- owner command now validates preset syntax before activation
- invalid or missing activation attempts no longer overwrite the active selector
- owner profile lifecycle is now more ergonomic while remaining deterministic
- login, selector and effective runtime source remain coherent under command-driven switching
- E2E boot scenario now validates owner command help, list, current, valid activation, missing activation rejection and invalid activation rejection
- sprint validated end-to-end with score=100 warn=0 errors=0

## artifacts
- /home/kao/bin/kao
- /home/kao/bin/kao-owner
- /home/kao/tests/e2e/scenarios/boot_check.sh
- /home/kao/README.md
- /home/kao/state/sprints/sprint-2.1.md

## validation
- kao owner help displays canonical owner command usage
- kao owner list displays available presets and their validity state
- kao owner current displays selector and resolved preset state
- kao owner use <preset> activates only a valid existing preset
- missing preset activation fails explicitly
- invalid preset activation fails explicitly
- failed activation attempts preserve the previous selector
- login remains coherent with the selector written by the owner command
- E2E validates owner command lifecycle and boot coherence
- score=100
- warn=0
- errors=0

## workflow-integration
- owner preset lifecycle is now operable without manual file editing
- operator can inspect, validate and switch owner profiles through a dedicated command surface
- canonical owner management is now aligned with the effective login reading surface

## doctrine-impact
- multi-profile owner identity is now not only visible but operable
- canonical preset switching becomes a first-class command workflow
- preset lifecycle ergonomics now belong to the operator doctrine alongside deterministic boot resolution
- command-driven profile activation preserves legacy compatibility without weakening the canonical model

## next-entry-point
Sprint 2.2 — Owner preset creation and profile scaffold generation

# sprint-2.4

context: root
status: CONVERGED
goal: owner preset activation safety and selector administration hardening

## mission
owner preset activation safety and selector administration hardening

## result
- canonical owner command now supports explicit selector inspection through `kao owner selector`
- selector administration now distinguishes missing selector, invalid selector value, missing target and invalid target without ambiguity
- `kao owner current` now exposes selector mode and selector value in addition to active preset state
- `kao owner use <preset>` now validates activation more explicitly and verifies selector write after update
- activation output now shows before and after selector state for safer operator review
- invalid or missing activation attempts now preserve the previously active selector deterministically
- selector administration is now more explicit and operable without manual file opening
- owner.profile, owner presets, owner.env and boot resolution remain coherent together
- README now documents selector inspection doctrine and activation safety guarantees
- E2E boot scenario now validates selector inspection, selector state distinctions and activation safety preservation
- sprint validated end-to-end with selector administration hardening integrated

## artifacts
- /home/kao/bin/kao-owner
- /home/kao/tests/e2e/scenarios/boot_check.sh
- /home/kao/README.md
- /home/kao/state/sprints/sprint-2.4.md

## validation
- kao owner help displays selector command usage
- kao owner selector reports explicit selector file state
- selector inspection distinguishes missing selector, invalid selector value, missing target and invalid target
- kao owner current exposes selector mode and selector value clearly
- kao owner use <preset> shows before and after selector values
- use validates target preset before any selector write
- use rejects missing presets explicitly
- use rejects invalid presets explicitly
- failed activation attempts do not overwrite the current selector
- boot remains coherent when selector is invalid and legacy fallback is used
- E2E validates full selector and activation safety workflow

## workflow-integration
- owner lifecycle now includes selector inspection before or after activation when operator wants to audit the active pointer
- operator can verify whether the selector itself is healthy without manually opening config files
- activation remains explicit, reversible and readable from terminal output
- selector administration becomes a first-class canonical operation in the owner workflow

## doctrine-impact
- multi-profile owner identity now includes explicit selector governance
- activation safety becomes part of the owner doctrine
- command-driven selector inspection reduces ambiguity around active profile state
- deterministic runtime resolution remains preserved while selector management becomes more robust

## next-entry-point
Sprint 2.5 — Owner selector recovery and canonical deactivation workflow

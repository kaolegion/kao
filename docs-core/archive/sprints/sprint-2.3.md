# sprint-2.3

context: root
status: CONVERGED
goal: owner preset inspection and canonical metadata editing workflow

## mission
owner preset inspection and canonical metadata editing workflow

## result
- canonical owner command now supports preset inspection through `kao owner inspect <preset>`
- canonical owner command now supports controlled metadata editing through `kao owner edit <preset> <field> <value>`
- preset inspection now exposes resolved owner metadata field by field with explicit required, optional, visible and hidden grouping
- preset inspection now shows unset canonical fields explicitly instead of leaving ambiguity
- preset editing now rewrites preset files through a canonical command path instead of risky manual editing
- preset editing is now restricted to the allowed canonical owner fields only
- preset editing now preserves selector stability and does not silently activate profiles
- preset creation, inspection, editing and activation are now clearly separated lifecycle actions
- owner preset management now remains coherent with owner.profile, owner.env and boot resolution
- README now documents inspect and edit workflows, allowed fields and doctrine impact
- E2E boot scenario now validates inspect, edit, invalid field rejection, missing preset rejection and canonical rewrite behavior
- sprint validated end-to-end with score=100 warn=0 errors=0

## artifacts
- /home/kao/bin/kao-owner
- /home/kao/tests/e2e/scenarios/boot_check.sh
- /home/kao/README.md
- /home/kao/state/sprints/sprint-2.3.md

## validation
- kao owner help displays inspect and edit command usage
- kao owner inspect <preset> displays canonical grouped metadata for an existing preset
- inspect shows unset hidden fields explicitly
- kao owner inspect <preset> fails explicitly when the preset is missing
- kao owner edit <preset> <field> <value> updates the targeted canonical field
- edit performs a canonical rewrite that stays syntax-valid
- edit preserves non-targeted canonical fields coherently
- edit rejects non-allowed fields explicitly
- edit rejects missing presets explicitly
- edit does not activate the preset automatically
- owner list, owner current and boot remain coherent after inspect/edit lifecycle operations
- E2E validates full workflow end-to-end
- score=100
- warn=0
- errors=0

## workflow-integration
- owner lifecycle now includes inspect before activation when operator wants to verify a profile
- owner lifecycle now includes canonical edit before activation when metadata must evolve
- operator can inspect and update owner identity presets without opening files manually
- preset authoring and preset activation remain clearly separated in terminal workflow

## doctrine-impact
- multi-profile owner identity now supports canonical introspection of each preset
- canonical owner metadata editing becomes part of the owner doctrine
- command-driven metadata mutation reduces manual file editing risk
- deterministic resolution and legacy compatibility remain preserved while owner administration becomes more operable

## next-entry-point
Sprint 2.4 — Owner preset activation safety and selector administration hardening

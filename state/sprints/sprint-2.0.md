# sprint-2.0

context: root
status: CONVERGED
goal: owner identity presets and canonical profile switching

## mission
owner identity presets and canonical profile switching

## result
- canonical owner identity now supports reusable presets stored under /home/kao/profiles/owners
- canonical active owner profile is now selected through /home/kao/config/owner.profile
- login now preserves a single active and deterministic owner source at runtime
- owner block now distinguishes active profile, profile status and available presets
- canonical preset resolution is now explicit and operator-readable in terminal
- valid active preset switches login identity to the targeted canonical preset
- missing active preset is now explicitly reported and falls back deterministically to legacy owner file
- invalid active preset is now explicitly reported and falls back deterministically to legacy owner file
- legacy owner.env remains supported as deterministic compatibility fallback
- owner model marker now reflects multi-profile owner identity
- E2E boot scenario now validates legacy mode, valid preset mode, missing preset fallback and invalid preset fallback
- sprint validated end-to-end with score=100 warn=0 errors=0

## artifacts
- /home/kao/bin/kao-boot
- /home/kao/tests/e2e/scenarios/boot_check.sh
- /home/kao/README.md
- /home/kao/state/sprints/sprint-2.0.md

## validation
- login displays active profile
- login displays profile status
- login displays available presets
- login keeps deterministic legacy fallback when no selector exists
- login switches to canonical preset when active preset is valid
- login reports missing preset and falls back to legacy source
- login reports invalid preset and falls back to legacy source
- E2E validates legacy mode
- E2E validates canonical preset mode
- E2E validates missing preset fallback mode
- E2E validates invalid preset fallback mode
- score=100
- warn=0
- errors=0

## workflow-integration
- owner identity can now be operated through reusable preset files instead of a single static identity source
- canonical profile switching is now visible directly from the login reading surface
- terminal operator can distinguish chosen profile, profile health and effective active source at boot time

## doctrine-impact
- owner identity is no longer mono-profile only
- canonical profile selection is now first-class in the identity model
- preset availability, active selection and invalid states are part of operator-visible boot doctrine
- legacy compatibility is preserved without weakening the canonical preset model

## next-entry-point
Sprint 2.1 — Owner profile management command and preset lifecycle ergonomics

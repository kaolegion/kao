# sprint-1.9

context: root
status: CONVERGED
goal: owner identity visible metadata activation and richer human login rendering

## mission
owner identity visible metadata activation and richer human login rendering

## result
- canonical owner block now activates visible human metadata directly in login
- title, handle and organization are now readable by default in the owner block
- email and domain are now explicitly classified as hidden-by-default fields
- owner presentation now preserves a clear hierarchy between primary identity and human enrichment
- owner block is now more human without losing terminal compactness
- source policy and source value remain explicitly visible
- boot policy now distinguishes visible-now fields from hidden-default fields
- E2E boot scenario is now self-contained and no longer depends on a pre-existing owner.env file on disk
- nominal owner fixture values are now correctly quoted for deterministic extraction
- README was aligned with visible human metadata activation and hidden-default policy
- canonical humanized owner presentation was validated end-to-end in terminal

## artifacts
- /home/kao/bin/kao-boot
- /home/kao/tests/e2e/scenarios/boot_check.sh
- /home/kao/README.md
- /home/kao/state/sprints/sprint-1.9.md

## validation
- login displays required owner name
- login displays optional owner role
- login displays optional owner id
- login displays visible owner title
- login displays visible owner handle
- login displays visible owner organization
- login displays visible-now policy
- login displays hidden-default policy
- login displays source policy
- login displays source value
- login displays humanized owner model marker
- boot survives invalid owner source
- invalid owner source keeps deterministic field fallbacks
- E2E validates nominal and invalid owner source with humanized visible metadata policy
- score=100
- warn=0
- errors=0

## workflow-integration
- canonical login now exposes richer human identity directly in the operator reading surface
- owner presentation remains policy-aware while becoming more personal and operable
- E2E boot proof is now self-contained regarding owner.env setup and deterministic nominal fixtures

## doctrine-impact
- owner identity now includes a visible human layer beyond strict technical identity
- default visible metadata is limited to non-sensitive human enrichment
- sensitive or secondary owner fields remain intentionally hidden by default
- future owner presentation changes must preserve hierarchy, compactness and explicit policy

## next-entry-point
Sprint 2.0 — Owner identity presets and canonical profile switching

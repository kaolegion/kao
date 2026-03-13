# sprint-1.4

context: root
status: CONVERGED
goal: canonical login e2e assertions and owner metadata extension

## mission
canonical login e2e assertions and owner metadata extension

## result
- boot scenario extended with canonical login assertions
- E2E now checks MACHINE/SYSTEM/OWNER/KAO visibility
- E2E now checks owner source visibility
- E2E now checks root prompt visibility
- owner metadata source extended with role and id fields
- README aligned with owner metadata growth
- owner.env quoting fixed for shell-safe sourcing
- canonical login assertions validated end-to-end

## artifacts
- /home/kao/tests/e2e/scenarios/boot_check.sh
- /home/kao/config/owner.env
- /home/kao/README.md
- /home/kao/state/sprints/sprint-1.4.md

## validation
- E2E boot scenario validates canonical login blocks
- owner metadata file contains extensible fields
- canonical login boot remains readable and compatible
- full E2E passes after owner metadata extension
- score=100
- warn=0
- errors=0
- log=/home/kao/state/e2e/session-20260313-053437.log

## workflow-integration
- boot validation now asserts canonical login structure directly
- owner config growth is now covered by shell-safe sourcing rules
- login readability is now part of the E2E proof layer

## doctrine-impact
- canonical login is no longer only visually improved, it is now test-enforced
- owner metadata can evolve without losing deterministic boot validation
- future login changes must preserve E2E-visible machine/system/owner/kao blocks

## next-entry-point
Sprint 1.5 — Dynamic owner metadata display in canonical login

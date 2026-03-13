# sprint-3.2

context: root
status: CONVERGED
goal: runtime user activation command and policy workflow

## mission
introduce canonical runtime user activation and deactivation commands with a clear policy-aware state machine.

## result
- canonical command `kao user activate` added
- canonical command `kao user deactivate` added
- runtime user activation now requires a valid `config/user.env`
- runtime user deactivation is deterministic and safe
- runtime user state model normalized to `INACTIVE / AVAILABLE / ACTIVE / INVALID`
- boot scene now reflects owner-only or owner-user runtime states immediately
- owner remains the primary active authority
- active entities become `owner user` only when runtime user is explicitly active
- new dedicated e2e scenario validates the full runtime user activation workflow

## files
- /home/kao/bin/kao
- /home/kao/bin/kao-user
- /home/kao/bin/kao-boot
- /home/kao/lib/kao-user-state.sh
- /home/kao/tests/e2e/scenarios/boot_check.sh
- /home/kao/tests/e2e/scenarios/operator_flow.sh
- /home/kao/tests/e2e/scenarios/user_activation_flow.sh
- /home/kao/tests/e2e/run_e2e.sh
- /home/kao/state/sprints/sprint-3.2.md

## incident log
- verification exposed a boot regression: `/home/kao/lib/kao-owner-state.sh` required `OWNER_SELECTOR_OFF` but `/home/kao/bin/kao-boot` no longer defined it
- observable symptom: `kao-boot` aborted before rendering, causing cascading E2E failures on boot assertions
- hotfix applied: restored `OWNER_SELECTOR_OFF="OFF"` in `kao-boot`
- rule reinforced: any surfaced conversation/runtime error must be logged in the active sprint note before moving forward


# sprint-3.1

context: root
status: IN_VALIDATION
goal: user runtime identity foundation and canonical activation model

## mission
user runtime identity foundation and canonical activation model

## result
- a canonical runtime user state library now exists at /home/kao/lib/kao-user-state.sh
- the runtime user model now distinguishes placeholder, absent, available, and active states
- kao-boot now resolves and renders canonical runtime user identity from config/user.env and config/user.state
- owner remains the primary active authority while user is not explicitly activated
- when a valid runtime user source exists without activation, user is rendered as available and remains contextual
- when runtime user activation is explicit and valid, user becomes active in the login scene alongside owner
- when activation is requested without a valid runtime source, user is rendered as absent with repair guidance
- the login scene now exposes explicit runtime user mode, label, relation, hint, and canonical user fields
- boot_check E2E now validates placeholder, available, active, and absent runtime user states
- operator_flow E2E now validates user runtime transitions while preserving owner authority behavior
- sprint 3.1 establishes the canonical user runtime foundation for future activation and deactivation workflows without breaking the current owner hierarchy

## artifacts
- /home/kao/lib/kao-user-state.sh
- /home/kao/bin/kao-boot
- /home/kao/tests/e2e/scenarios/boot_check.sh
- /home/kao/tests/e2e/scenarios/operator_flow.sh
- /home/kao/state/sprints/sprint-3.1.md

## expected-validation
- kao-user-state.sh loads and emits canonical runtime user state
- kao-boot renders placeholder user state when no runtime source exists
- kao-boot renders available user state when user.env exists without activation
- kao-boot renders active user state when user.env is valid and user.state is active
- kao-boot renders absent user state when activation is requested without a valid runtime source
- owner remains the main active authority until runtime user activation is explicit
- boot_check scenario loads and validates successfully
- operator_flow scenario loads and validates successfully
- full e2e suite completes successfully

## final-validation
- pending re-run after tolerant owner-use policy-state match including repair

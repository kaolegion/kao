# sprint-2.9

context: root
status: CONVERGED
goal: owner login humanization and machine/system/user rendering policy

## mission
owner login humanization and machine/system/user rendering policy

## result
- kao-boot login scene now renders an explicit machine / system / owner hierarchy
- machine identity is now displayed separately through machine host and machine role
- system identity is now displayed separately through system name, role, root, bin, layer, and scene
- active owner identity remains resolved through the current preset / selector / runtime policy
- owner presentation is now more humanized without breaking terminal readability
- selector/runtime policy visibility remains preserved inside the login scene
- boot_check E2E now validates the new machine/system/owner login rendering
- operator_flow E2E now validates the new machine/system/owner login rendering
- sprint 2.9 establishes the rendering base for a future machine/system/human login scene evolution

## artifacts
- /home/kao/bin/kao-boot
- /home/kao/tests/e2e/scenarios/boot_check.sh
- /home/kao/tests/e2e/scenarios/operator_flow.sh
- /home/kao/state/sprints/sprint-2.9.md

## expected-validation
- kao-boot renders a login scene header
- kao-boot renders machine host and machine role
- kao-boot renders system name, role, and scene
- kao-boot renders owner identity and owner source
- selector/runtime state remains visible in boot output
- boot_check scenario loads and validates successfully
- operator_flow scenario loads and validates successfully
- full e2e suite completes successfully

## final-validation
- pending full sprint validation

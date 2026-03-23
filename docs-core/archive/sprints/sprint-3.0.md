# sprint-3.0

context: root
status: CONVERGED
goal: canonical multi-entity login scene and explicit machine/system/owner/user rendering model

## mission
canonical multi-entity login scene and explicit machine/system/owner/user rendering model

## result
- kao-boot login scene now renders an explicit machine / system / owner / user hierarchy
- machine and system are now explicitly marked as structural entities
- active owner identity remains the active runtime human authority rendered from the current selector / preset / runtime model
- a stable user block now exists as a contextual operator placeholder for future runtime evolution
- the login scene now distinguishes structural entities, active entities, and contextual entities
- owner preset / selector / runtime compatibility remains preserved
- boot_check E2E now validates machine/system/owner/user rendering and entity classes
- operator_flow E2E now validates machine/system/owner/user rendering and entity classes
- sprint 3.0 establishes the canonical login scene base for future user-operatoire integration without breaking the current owner model

## artifacts
- /home/kao/bin/kao-boot
- /home/kao/tests/e2e/scenarios/boot_check.sh
- /home/kao/tests/e2e/scenarios/operator_flow.sh
- /home/kao/state/sprints/sprint-3.0.md

## expected-validation
- kao-boot renders machine class, system class, owner class, and user class
- kao-boot renders system scene as machine / system / owner / user
- kao-boot renders a stable contextual user placeholder
- kao-boot renders structural, active, and contextual entity categories
- boot_check scenario loads and validates successfully
- operator_flow scenario loads and validates successfully
- full e2e suite completes successfully

## final-validation
- pending full sprint validation

#!/usr/bin/env bash

. /home/kao/tests/e2e/lib_e2e.sh
. /home/kao/tests/e2e/scenarios/boot_check.sh
. /home/kao/tests/e2e/scenarios/operator_flow.sh
. /home/kao/tests/e2e/scenarios/user_activation_flow.sh
. /home/kao/tests/e2e/scenarios/user_profile_source_flow.sh
. /home/kao/tests/e2e/scenarios/user_patch_flow.sh
. /home/kao/tests/e2e/scenarios/error_recovery.sh
. /home/kao/tests/e2e/scenarios/gateway_infer.sh
. /home/kao/tests/e2e/scenarios/ray_surface.sh
. /home/kao/tests/e2e/scenarios/ray_system_inspect.sh
. /home/kao/tests/e2e/scenarios/ray_timeline.sh
. /home/kao/tests/e2e/scenarios/ray_session_timeline_v2.sh
. /home/kao/tests/e2e/scenarios/runtime_surface.sh

e2e_init

scenario_boot_check
scenario_operator_flow
scenario_user_activation_flow
scenario_user_profile_source_flow
scenario_user_patch_flow
scenario_error_recovery
scenario_gateway_infer
scenario_ray_surface
scenario_ray_system_inspect
scenario_ray_timeline
scenario_ray_session_timeline_v2
scenario_runtime_surface

e2e_finalize

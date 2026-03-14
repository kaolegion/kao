#!/usr/bin/env bash

. /home/kao/lib/ksl/nav/ksl_temporal_nav.sh
. /home/kao/lib/ksl/ksl_dashboard.sh

ksl_dashboard_demo_seed() {
    mkdir -p /home/kao/state/runtime

    cat > /home/kao/state/runtime/session.timeline <<'EOT'
2026-03-14T20:10:00Z | EVENT=session.start | SIGNAL=•/SYS/active/i2/blink-triple/session
2026-03-14T20:10:02Z | EVENT=network.up | SIGNAL=⌁/NET/active/i2/pulse-slow/network
2026-03-14T20:10:04Z | EVENT=router.gateway | SIGNAL=◆/SYS/active/i3/pulse-fast/router
2026-03-14T20:10:05Z | EVENT=router.local.ready | SIGNAL=◆/SYS/success/i1/hold/router
2026-03-14T20:10:07Z | EVENT=agent.call.timeline | SIGNAL=▮/ACT/active/i2/pulse-slow/agent
2026-03-14T20:10:08Z | EVENT=agent.call.watcher | SIGNAL=▮/ACT/active/i2/pulse-slow/agent
2026-03-14T20:10:09Z | EVENT=agent.done.timeline | SIGNAL=▮/ACT/success/i1/fade/agent
2026-03-14T20:10:10Z | EVENT=agent.idle.watcher | SIGNAL=▮/ACT/idle/i1/hold/agent
2026-03-14T20:10:11Z | EVENT=focus.shift.dashboard | SIGNAL=⌁/SYS/active/i1/pulse-slow/focus
2026-03-14T20:10:12Z | EVENT=projection.roadmap | SIGNAL=⌁/SYS/projection/i1/pulse-future/timeline
EOT
}

ksl_dashboard_demo() {
    ksl_dashboard_demo_seed
    ksl_timeline_jump_end
    ksl_dashboard_render
}

ksl_dashboard_demo

# KAO — User Manual

## Purpose of this manual

This manual describes operational use of Kao.

It is intended for a Linux operator who wants to:

- understand how the system works
- execute commands safely
- govern runtime
- diagnose a situation
- stabilize an incoherent state
- understand routing decisions
- understand model registry reading

This manual describes an operable cognitive system.

---

## Canonical inference command

Main inference entrypoint:

- brain infer "<query>"

Execution flow:

1. gateway loads secrets if present
2. gateway evaluates cloud readiness
3. gateway evaluates local readiness
4. gateway computes routing decision
5. gateway reads registry model context
6. gateway executes inference
7. route signal is exposed
8. runtime trace is written to logs

---

## Hybrid router operator surface (ray)

Ray provides a compact **decision-reading surface**.

Commands:

- ray
- ray status
- ray registry
- ray scout
- ray ask "<prompt>"
- ray run "<prompt>"

Ray exposes routing cognition,
not only provider availability.

Ray also exposes a first readable
internal model registry.

Ray also exposes a first strategic
multi-entry model landscape reading
for ranked registry entries.

Ray now also exposes a first
operator intent classification layer
through `ray ask`.

---

## Understand ray scout reading

`ray scout` shows the ranked
model landscape in a compact
operator format.

It exposes:

- provider
- model
- family
- maturity
- rank
- status

This view is:

- deterministic
- read-only
- comparative across ranked registry entries
- ordered by registry rank
- independent from routing mutation

Strategic status is currently mapped as:

- elite → dominant
- high → competitive
- medium → viable
- low → incubating
- unknown → experimental

This mapping is informational only.

It does not change routing yet.

---

## Understand ray registry reading

`ray registry` shows the internal canonical model registry.

This registry is:

- deterministic
- local to Kao runtime
- independent from real routing decision
- designed to prepare future ranking logic

Each entry exposes:

- provider
- model
- family (cloud / local)
- base score
- declared state
- runtime state
- runtime score
- operator rank
- maturity level

Declared state reflects
the canonical registry declaration.

Runtime state reflects
the actual runtime situation.

Runtime score is derived from:

- base score
- runtime readiness

Operator rank is derived from:

- runtime score
- declared registry posture

Maturity level gives a compact operator reading such as:

- low
- medium
- high
- elite

These values are **informational only** at this stage.

Routing still follows gateway policy.

---

## Understand ray decision reading

Ray exposes:

### Selected route

- cloud
- local
- none

### Decision state

This describes whether the router
can actually retain a routing decision.

It is distinct from:

- the raw forcing input
- the normalized provider reading
- the global runtime capability
- the registry reading

Possible values:

- route-selected
- no-route-selected
- blocked-unsupported-forcing

---

## Route reason

Explains *why* the route was selected
or why the routing decision is blocked.

Possible values:

- cloud-priority-ready
- local-only-available
- forced-provider-mistral
- forced-provider-ollama
- unsupported-forced-provider
- no-provider-ready

This is the first human-readable decision layer.

---

## Understand routing scores

Ray exposes three compact routing scores:

- cloud score
- local score
- route score

Ray also exposes:

- registry base score
- registry runtime score
- registry operator rank
- registry maturity
- scout strategic status

Interpretation:

- routing scores describe decision strength
- registry score describes runtime-weighted registry value
- registry operator rank describes comparative operator priority
- registry maturity describes compact maturity reading
- scout strategic status describes the comparative model landscape posture

Registry and scout values do not change routing yet.

---

## Operator mode reading

Ray exposes:

- online
- offline
- degraded
- hybrid-ready

Meaning:

- online → effective decision uses cloud route
- offline → effective decision uses local route
- degraded → decision cannot be retained or routing unstable
- hybrid-ready → both route families are operationally usable

---

## Hybrid state reading

Hybrid state describes **runtime capability**, not the decision.

Values:

- hybrid-ready
- cloud-only
- local-only
- unavailable

---

## Important decision case — unsupported forcing

If the operator forces a provider that is not supported:

- forced raw value keeps the operator input as expressed
- forced provider remains the normalized supported reading
- forced state becomes `unsupported`
- routing decision can become blocked
- selected route can become `none`
- decision state becomes `blocked-unsupported-forcing`
- operator mode becomes `degraded`

However:

- hybrid state can still be `hybrid-ready`
- registry reading still exists
- runtime capacity still exists

This means:

routing cognition is blocked,
not runtime capability.

---

## Recommended operator workflow

Before running inference:

1. read ray status
2. read ray registry
3. read ray scout
4. understand decision state
5. understand route reason
6. evaluate routing scores
7. evaluate registry and scout reading
8. decide whether to force a provider
9. run inference

If deeper diagnosis is needed:

- read kao gateway
- read kao gateway logs

---

## Routing doctrine

Priority order:

1. forced provider
2. cloud ready route
3. local ready route
4. degraded state

Registry reading does not override routing policy yet.

Cloud remains default production route.

Local evolves progressively toward autonomy.

Registry prepares:

- ranking logic
- runtime maturity reading
- future comparative provider/model evolution
- multi-LLM cognition
- adaptive routing intelligence

---

## Runtime logs

Runtime events are written in:

- state/logs/gateway.log

Logs show:

- route attempts
- real vs stub execution
- fallback events
- target model states

Cockpit commands must not pollute runtime logs.

---

## Goal of the hybrid router

Prepare Kao for:

- adaptive multi-LLM routing
- autonomous offline cognition
- agentic orchestration
- ranking-aware routing
- human-readable model landscape


## Understand ray ask reading

`ray ask "<prompt>"` classifies a prompt
before real execution.

It currently exposes:

- prompt
- intent
- route family
- action label
- provider when an LLM family is implied

Current intent classes are:

- file-op
- system-op
- cognitive-light
- cognitive-heavy
- unknown

Current route families are:

- local-agent
- llm-light
- llm-heavy
- unknown

Current action labels are:

- filesystem operator
- system operator
- light cognitive inference
- deep cognitive inference
- unclassified

This layer is currently:

- déterministe
- heuristique
- read-only
- non-agentic in execution
- designed to prepare future orchestration

`ray ask` does not execute inference.

It exposes a cognitive reading surface
before `ray run` or `brain infer`.

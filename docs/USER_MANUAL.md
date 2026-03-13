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
5. gateway executes inference
6. route signal is exposed
7. runtime trace is written to logs

---

## Hybrid router operator surface (ray)

Ray provides a compact decision-reading surface.

Commands:

- ray
- ray status
- ray run "<prompt>"

Ray exposes **decision cognition**, not only routing state.

---

## Understand ray decision reading

Ray now exposes:

### Selected route

- cloud
- local
- none

### Route reason

Explains *why* the route was selected.

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

Ray exposes three compact scores:

- cloud score  
- local score  
- route score  

Interpretation:

- cloud score → relative strength of cloud route
- local score → relative maturity of local route
- route score → score of the actually selected route

Typical reading:

- cloud score high → secrets present and provider ready
- local score medium → local stub usable
- local score high → real local inference possible
- route score low → degraded routing situation

Scores are deterministic and intended for operator reasoning.

---

## Operator mode reading

Ray exposes:

- online  
- offline  
- degraded  
- hybrid-ready  

Meaning:

- online → only cloud usable
- offline → only local usable
- degraded → routing unstable
- hybrid-ready → both routes usable

---

## Hybrid state reading

- hybrid-ready  
- cloud-only  
- local-only  
- unavailable  

This expresses global routing capability.

---

## Recommended operator workflow

Before running inference:

1. read ray status
2. understand route reason
3. evaluate scores
4. decide whether to force a provider
5. run inference

If deeper diagnosis is needed:

- read kao gateway
- read kao gateway logs

This prevents blind routing usage.

---

## Routing doctrine

Priority order:

1. forced provider
2. cloud ready route
3. local ready route
4. degraded state

Cloud remains default production route.

Local evolves progressively toward autonomy.

Ray helps the operator **understand routing cognition**.

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
- human-readable decision layers

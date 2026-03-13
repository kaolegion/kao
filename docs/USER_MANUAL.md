# KAO — User Manual

## Purpose of this manual

This manual describes operational use of Kao.

It is intended for a Linux operator who wants to:

- understand how the system works
- execute commands safely
- govern runtime
- diagnose a situation
- stabilize an incoherent state

This manual describes an operable cognitive system.

---

## General structure of Kao

Kao is organized as an operator system in user space.

Main directories:

- `bin/` executable commands
- `config/` configuration sources
- `lib/` internal logic
- `state/` runtime states and logs
- `tests/` validation scenarios
- `docs/` product documentation

This allows:

- direct inspection
- controlled modification
- deterministic understanding

---

## Canonical inference command

The main inference entrypoint is:

- `brain infer "<query>"`

Execution flow:

1. gateway loads external secrets if present  
2. gateway selects provider  
3. gateway executes inference  
4. route is exposed in terminal  
5. runtime trace is written to `state/logs/gateway.log`

Typical route signals:

- `gateway -> mistral cloud`
- `gateway -> ollama local`
- `gateway fallback -> ollama local`

These signals describe the real execution path.

---

## Gateway inspection commands

Operator cockpit:

- `kao gateway`
- `kao gateway health`
- `kao gateway logs`

These commands:

- expose readable diagnostic state
- do not pollute runtime logs
- help understand readiness before inference

---

## Hybrid router operator surface (ray)

Ray provides a more compact reading of routing cognition.

Command surface:

- `ray`
- `ray status`
- `ray run "<prompt>"`
- `ray "<prompt>"`

Ray does not replace `brain infer`.

Ray simplifies operator perception of:

- real execution route
- hybrid cloud/local state
- global readiness situation

---

## Understand ray reading

Ray exposes:

### Selected route

- `cloud`
- `local`
- `none`

### Operator mode

- `online`
- `offline`
- `degraded`
- `hybrid-ready`

Meaning:

- online → only cloud is usable  
- offline → only local is usable  
- degraded → no provider is fully ready  
- hybrid-ready → both cloud and local are usable  

### Hybrid state

- `hybrid-ready`
- `cloud-only`
- `local-only`
- `unavailable`

This describes global routing capability.

---

## Understand local provider progression

Ollama local provider readiness:

- `unavailable`
- `local-stub-ready`
- `local-real-backend-ready`
- `local-real-ready`

Meaning:

- stub-ready → development path usable  
- backend-ready → runtime reachable but model not ready  
- real-ready → real local inference possible  

---

## Understand local model state

Model states:

- `unknown`
- `missing`
- `ready`

Runtime states:

- `stub-runtime`
- `real-backend-ready`
- `real-model-ready`
- `unavailable`

---

## Understand local real-call policy

Policy:

- `enabled`
- `disabled`

Real execution states:

- `callable`
- `blocked-policy`
- `blocked-no-model`
- `stub-only`
- `unavailable`

This allows safe evolution toward offline cognition.

---

## Routing doctrine

Priority:

1. forced provider  
2. mistral cloud  
3. ollama local  
4. fallback mistral → ollama  

Cloud remains default production route.

Local inference is progressive capability.

Ray helps read this hybrid cognition faster.

---

## Understand gateway runtime logs

Runtime events are written in:

- `state/logs/gateway.log`

Logs distinguish:

- real inference attempts  
- stub inference  
- fallback paths  
- target model state  

Cockpit commands must not pollute this log.

---

## Recommended operator workflow

Before inference:

- read `ray status`

If detailed diagnosis needed:

- read `kao gateway`

If execution unclear:

- read `kao gateway logs`

This sequence reduces routing confusion
and improves cognitive stability.


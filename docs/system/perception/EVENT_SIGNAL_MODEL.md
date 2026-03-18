# KAO EVENT SIGNAL MODEL

## Purpose

Defines the minimal canonical signal line produced by runtime normalization.

Pipeline:

event source
→ state/runtime/events.raw.log
→ event_normalizer.sh
→ state/sense/signals.log

## Raw line

format:
ts|raw_type|payload

example:
1710712345|COMMAND_RUN|kao ask hello

## Signal line

format:
ts|source|domain|event|payload

example:
1710712345|operator|command|run|kao ask hello

## Rules

- raw log append only
- signal log append only
- unknown events must degrade safely
- format must stay grep-friendly

## Operator micro-perception signals

Kao may emit ultra-fine perception signals originating from operator interaction.

These signals are first-class runtime signals and must respect the canonical format:

ts|source|domain|event|payload

### Purpose

- capture operator rhythm
- detect lexical emergence
- enrich cognitive heat
- enable future predictive assistance
- maintain append-only historical trace

### Domain

domain:
input

### Event types

key

example:
1710712346|operator|input|key|a
1710712347|operator|input|key|backspace

token

example:
1710712348|operator|input|token|putain

sequence

example:
1710712349|operator|input|sequence|p...

pause

example:
1710712350|operator|input|pause|1200ms

### Constraints

- emission must remain synchronous inline
- no heavy analysis during capture
- raw and signal logs remain append only
- aggregation must happen later in dedicated cognitive engines
- router may consume derived heat, not raw interpretation
- normalizer must treat these signals as canonical events

### Strategic role

Operator micro-perception is part of Kao cognitive physiology.

It may support:

- adaptive routing sensitivity
- linguistic heat mapping
- long-term operator signature modelling
- future sovereign autocomplete capabilities

# KAO — Pull Requests

## Intent

This document defines the expected shape of a good change proposal in Kao.

A pull request should make the project easier to inspect,
not harder to understand.

---

## Expected PR structure

A good pull request should explain:

- what changed
- why it changed
- which files were touched
- how the change was verified
- whether docs were updated
- whether tests were updated

---

## Preferred PR style

Kao favors pull requests that are:

- small
- explicit
- convergent
- easy to review
- backed by verification output

---

## Review expectations

Before considering a change complete, verify:

- target files were re-inspected before modification
- behavior is coherent
- docs match the change
- tests match the change when relevant
- final repo state is readable

---

## Anti-patterns

Avoid pull requests that are:

- too large to inspect calmly
- under-documented
- weakly verified
- mixing unrelated concerns
- drifting away from canonical runtime doctrine

---

## Final principle

A good pull request should help maintain
clarity, determinism and documentation convergence.


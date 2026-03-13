# KAO — Issues

## Intent

This document explains how to raise a useful issue in Kao.

It applies to:

- bugs
- documentation problems
- architecture inconsistencies
- runtime behavior questions
- feature ideas grounded in project direction

---

## Good issue structure

A good issue should include:

- context
- affected file or command
- expected behavior
- observed behavior
- reproduction steps when possible
- current verification evidence

---

## Preferred issue style

Kao favors issues that are:

- explicit
- testable
- inspectable
- grounded in current file state
- small enough to act on clearly

---

## Useful evidence

Depending on the issue, include when relevant:

- `pwd`
- exact command used
- `sed -n` inspection of related files
- verification output
- current `git status`
- runtime state summary

---

## Documentation issues

If the issue concerns docs, specify whether the problem is:

- missing documentation
- outdated documentation
- inconsistent documentation
- unclear project entrypoint
- mismatch between docs and runtime behavior

---

## Final principle

A good issue should reduce ambiguity
and help the next correction step stay surgical.


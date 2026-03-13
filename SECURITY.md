# KAO — Security Policy

## Intent

Kao is built as an operator-facing system.

Security issues should be handled with care,
clarity and responsible disclosure.

---

## What should be reported

Please report issues that may affect:

- runtime integrity
- command safety
- identity resolution
- configuration handling
- privilege boundaries
- sensitive data exposure
- destructive behavior triggered unexpectedly

---

## Reporting guidance

When reporting a security issue, include if possible:

- affected file or command
- observed behavior
- expected safe behavior
- reproduction steps
- potential impact
- suggested mitigation if known

Keep reports factual and reproducible.

---

## Disclosure preference

Please avoid publishing unpatched
high-risk issues publicly before maintainers
have had a reasonable chance to inspect them.

Responsible disclosure helps protect users,
contributors and downstream deployments.

---

## Scope note

Kao is still evolving.

Some parts of the project may remain experimental,
but security-sensitive behavior should still be reported
and documented explicitly.

---

## Operating principle

Kao favors:

- explicit behavior
- readable state transitions
- deterministic command paths
- minimal ambiguity around authority and runtime state

Security work should reinforce those principles.


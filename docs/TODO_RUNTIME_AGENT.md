# Runtime / Agent TODO

## Runtime Hardening

- Introduce mutation retry guard strategy
- Improve transaction recovery visibility
- Add runtime mutation metrics
- Implement read-only command classification system-wide

## Agent Architecture

- Extract operational agent responsibilities from Ray
- Design Bloom agent lifecycle and capabilities
- Define agent communication protocol with Kao kernel
- Clarify agent privilege boundaries

## Ray Evolution

- Define minimal kao-like distribution scope
- Reduce implicit dependencies on Kao runtime
- Formalise hybrid routing decision surface
- Split e2e test contracts (smoke vs advanced)

## Observability

- Improve runtime event tracing
- Add structured logs for router decisions
- Introduce runtime health summary command

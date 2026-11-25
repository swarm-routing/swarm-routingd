# CONTEXT.md — orientation and history

Background an agent or a new contributor needs that does not belong in
`AGENTS.md`: domain notes, current state, glossary, open questions. Read the
section a task needs, not the whole file.

## Current state

**Status: skeleton on swarm-core, partly deferred.** The org templates are
applied; the CMake C++23 skeleton (`src/`, `test/`, #29) builds
`swarm-routingd` on swarm-core 2.0.0 through vcpkg (#31), answers
`--version` and `--help`, and routes nothing. The daemon itself is epic #3:
re-planned up to #31 on 2026-11-24, the rest deferred by org ROADMAP decision
23 until the maintainer re-plans it. Its original five children live in
swarm-routing/.github (#255, #256, #258, #267, #548 there).

## Glossary

- **RouteDecision**: what a protocol core returns; the daemon carries it out
  as kernel routes and control messages (golden rule 10).
- **`RTPROT_SWARM` (88)**: the rtnetlink route protocol number the daemon's
  routes carry; it touches no other route.
- **`swarm0`**: the TUN catch-all; packets with no route yet wait in the
  bounded pending-packet queue.

## Open questions

- `check-swarm-core-pin.py` has no root-vcpkg layout yet
  (swarm-routing/.github#894), so there is no `swarm-core / pin` check here.
- The `swarm-routingd` port in swarm-routing/vcpkg-registry does not exist
  yet; `release.yml`'s `vcpkg-ports` needs it before the first release.

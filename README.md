# swarm-routingd

<!-- org-sync:begin badges -->
| Group | Badges |
| --- | --- |
| Build | [![Built on: ns3-dev](https://img.shields.io/badge/built%20on-ns3--dev%20image-blue?logo=docker)](https://github.com/orgs/swarm-routing/packages/container/package/ns3-dev) |
| Quality | [![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=swarm-routing_swarm-routingd&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=swarm-routing_swarm-routingd) [![Bugs](https://sonarcloud.io/api/project_badges/measure?project=swarm-routing_swarm-routingd&metric=bugs)](https://sonarcloud.io/summary/new_code?id=swarm-routing_swarm-routingd) [![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=swarm-routing_swarm-routingd&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=swarm-routing_swarm-routingd) [![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=swarm-routing_swarm-routingd&metric=sqale_rating)](https://sonarcloud.io/summary/new_code?id=swarm-routing_swarm-routingd) [![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/swarm-routing/swarm-routingd?utm_source=oss&utm_medium=github&utm_campaign=swarm-routing%2Fswarm-routingd&labelColor=171717&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit+Reviews)](https://coderabbit.ai) |
| Release | [![Release](https://img.shields.io/github/v/release/swarm-routing/swarm-routingd?sort=semver&cacheSeconds=1800)](https://github.com/swarm-routing/swarm-routingd/releases) [![Cite](https://img.shields.io/badge/cite-CITATION.cff-blue)](CITATION.cff) [![Licence: MIT OR GPL-2.0-only](https://img.shields.io/badge/licence-MIT%20OR%20GPL--2.0--only-blue)](LICENSING.md) |
| Trust | [![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/swarm-routing/swarm-routingd/badge)](https://scorecard.dev/viewer/?uri=github.com/swarm-routing/swarm-routingd) [![OpenSSF Best Practices](https://www.bestpractices.dev/projects/17077/badge)](https://www.bestpractices.dev/projects/17077) |
| Stack | [![C++23](https://img.shields.io/badge/C%2B%2B-23-blue?logo=cplusplus)](AGENTS.md) |
| Community & docs | [![Colony Arena: swarm-routingd](https://img.shields.io/badge/Colony%20Arena-project%20page-orange)](https://swarm-routing.github.io/projects/swarm-routingd/) [![Open RCAPA](https://img.shields.io/github/issues/swarm-routing/swarm-routingd/rcapa?label=open%20RCAPA&color=blue)](https://github.com/swarm-routing/swarm-routingd/blob/main/docs/rcapa/README.md) [![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow)](https://www.conventionalcommits.org) |
<!-- org-sync:end badges -->

swarm-routingd, the Linux runtime of the org's hexagonal layout (swarm-routing/.github#672, layer 2): a userspace daemon that runs the protocol cores on swarm-core's ports over real sockets: a single-threaded `epoll` reactor with `timerfd` and `signalfd`, routes synced through rtnetlink, a TUN catch-all with a pending-packet queue. CORE/EMANE and Shadow run it unmodified.

**Status: early, partly deferred.** A building, tested skeleton on swarm-core 2.1.0 through vcpkg (`swarm-routingd --version`); no routing yet. Epic #3 is re-planned up to #31; the reactor (#32) waits for swarm-routing/.github#894 and the maintainer's go-ahead, and the work beyond it stays deferred (org ROADMAP decision 23) until the maintainer re-plans it. Plan: epic #3 and swarm-routing/.github#672; release ladder (adopted 2026-11-25): [docs/roadmap.md](docs/roadmap.md).

- **Install:** [docs/install.md](docs/install.md): the supported Linux distributions, the required tools, through vcpkg or from source.
- **Threat model:** [docs/threat-model.md](docs/threat-model.md): the untrusted inputs, the one capability it holds (`CAP_NET_ADMIN`) and why, what is out of scope. Reporting: [SECURITY.md](SECURITY.md).

## Design rules

The org's golden rules 1–9 apply (licensing per directory, a one-way licence boundary, POD versioned wire formats, no module named `core`, determinism, paired comparisons, bounded structures, CI hygiene, nothing shipped on `.claude/`), plus the daemon's own, in full in [AGENTS.md](AGENTS.md#golden-rules-invariants--do-not-break):

10. **An adapter, not a router:** it carries out the `RouteDecision`s the protocol cores return; it holds no routing logic.
11. **Least capability and privilege:** `CAP_NET_ADMIN` only, as an unprivileged user; no threads, no `exec`; only its own routes (`RTPROT_SWARM` = 88).
12. **The threat model is part of the code:** every new input, capability or privilege updates [docs/threat-model.md](docs/threat-model.md) in the same PR.
13. **One thread, one clock:** a single-threaded `epoll` reactor on `timerfd` and `signalfd`, so Shadow and CORE/EMANE run it unmodified.

<!-- org-sync:begin develop -->
## Develop

New here? [docs/development.md](docs/development.md) is the developer guide:
the tools to install, how to get the code and its dependencies, how to
build, test, run and lint it, the Docker images, what CI checks and how to
read a red run. How changes are proposed, reviewed and released is the org's
[CONTRIBUTING.md](https://github.com/swarm-routing/.github/blob/main/CONTRIBUTING.md).
Whether a regression here gets an RCAPA (root cause analysis with corrective
and preventive actions), and how: [docs/rcapa/README.md](docs/rcapa/README.md).
<!-- org-sync:end develop -->

<!-- org-sync:begin citing -->
## Releases & citing

Versions follow [SemVer](https://semver.org). Each release is listed under [Releases](https://github.com/swarm-routing/swarm-routingd/releases), built by the org's release workflow and archived on [Zenodo](https://zenodo.org) with its own DOI.

To cite this repository, use the “Cite this repository” button (from [CITATION.cff](CITATION.cff)). It has no DOI yet: the concept DOI appears here and in the badge above once Zenodo archives its first release.

Using it in your work? Contributions are welcome, and citing it helps just as much.
<!-- org-sync:end citing -->

## Epics

<!-- epics:begin -->
<!-- Generated by swarm-routing/.github tools/epics/epics.py from the issues labelled `epic`; edit the issues, then re-run it. -->

What is planned and in progress here: the issues labelled [`epic`](https://github.com/swarm-routing/swarm-routingd/issues?q=label%3Aepic). An epic's open sub-issues carry a `priority:*` and a `model:*` label, so a contributor or an AI agent can pick one up ([how issues work](https://github.com/swarm-routing/.github/blob/main/CONTRIBUTING.md#issues)). The whole org's plan: the [roadmap](https://github.com/swarm-routing/.github/blob/main/ROADMAP.md#epics).

| Epic | Status | Sub-issues closed |
|------|--------|-------------------|
| [#3](https://github.com/swarm-routing/swarm-routingd/issues/3) Bootstrap swarm-routingd Linux daemon (epoll reactor, RtNetlinkSync, TUN, swarm-core ports) | In progress | 1 / 9 |

<!-- epics:end -->

## Licence

MIT OR GPL-2.0-only, the whole repository: see [LICENSING.md](LICENSING.md).

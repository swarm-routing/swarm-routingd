# swarm-routingd

<!-- org-sync:begin badges -->
| Group | Badges |
| --- | --- |
| Build | [![Built on: ns3-dev](https://img.shields.io/badge/built%20on-ns3--dev%20image-blue?logo=docker)](https://github.com/orgs/swarm-routing/packages/container/package/ns3-dev) |
| Quality | [![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=swarm-routing_swarm-routingd&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=swarm-routing_swarm-routingd) [![Bugs](https://sonarcloud.io/api/project_badges/measure?project=swarm-routing_swarm-routingd&metric=bugs)](https://sonarcloud.io/summary/new_code?id=swarm-routing_swarm-routingd) [![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=swarm-routing_swarm-routingd&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=swarm-routing_swarm-routingd) [![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=swarm-routing_swarm-routingd&metric=sqale_rating)](https://sonarcloud.io/summary/new_code?id=swarm-routing_swarm-routingd) [![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/swarm-routing/swarm-routingd?utm_source=oss&utm_medium=github&utm_campaign=swarm-routing%2Fswarm-routingd&labelColor=171717&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit+Reviews)](https://coderabbit.ai) |
| Release | [![Licence: MIT OR GPL-2.0-only](https://img.shields.io/badge/licence-MIT%20OR%20GPL--2.0--only-blue)](LICENSING.md) |
| Trust | [![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/swarm-routing/swarm-routingd/badge)](https://scorecard.dev/viewer/?uri=github.com/swarm-routing/swarm-routingd) |
| Stack | [![C++23](https://img.shields.io/badge/C%2B%2B-23-blue?logo=cplusplus)](AGENTS.md) |
| Community & docs | [![Open RCAPA](https://img.shields.io/github/issues/swarm-routing/swarm-routingd/rcapa?label=open%20RCAPA&color=blue)](https://github.com/swarm-routing/swarm-routingd/blob/main/docs/rcapa/README.md) [![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow)](https://www.conventionalcommits.org) |
<!-- org-sync:end badges -->

swarm-routingd, the Linux runtime of the org's hexagonal layout (swarm-routing/.github#672, layer 2): a userspace daemon that runs the protocol cores on swarm-core's ports over real sockets: a single-threaded `epoll` reactor with `timerfd` and `signalfd`, routes synced through rtnetlink, a TUN catch-all with a pending-packet queue. CORE/EMANE and Shadow run it unmodified.

**Status: planned.** Nothing is built yet; the plan is #3 and swarm-routing/.github#672.

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

## Licence

MIT OR GPL-2.0-only, the whole repository: see [LICENSING.md](LICENSING.md).

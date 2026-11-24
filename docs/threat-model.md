# Threat model

What swarm-routingd trusts, what it defends, what it holds and why, and
what is out of scope. It covers the daemon epic #3 plans; today the
repository holds only a skeleton that parses its own command line (#29).
Golden rule 12 (AGENTS.md): a change that adds an input, a capability, a
file, a socket or a privilege updates this page in the same pull request.
The reporting policy is [SECURITY.md](../SECURITY.md).

## What the daemon is

A userspace adapter: it hosts a protocol's simulator-free `core/` on
swarm-core's ports, feeds it the control messages it receives, and carries
out the `RouteDecision`s the core returns, as kernel routes and as control
messages on its own socket (golden rule 10). It makes no routing decision of
its own. It runs on testbeds, in network namespaces, and under CORE/EMANE
and Shadow.

## Assets

| Asset | Why it matters |
|-------|----------------|
| The host's routing tables | the daemon writes routes; a wrong route black-holes or diverts traffic |
| Traffic it forwards (the `swarm0` TUN catch-all) | packets wait in its pending-packet queue until a route exists |
| The host itself | a compromised daemon acts with whatever privilege it holds |

## Inputs and trust

| Input | Trusted? | Who parses it |
|-------|----------|---------------|
| UDP control datagrams on the routing interfaces | **no**: any host on the link can send them | the protocol core's bounds-checked little-endian reader (org golden rule 3), at the pinned swarm-core release; the daemon only copies the bytes in |
| Packets the kernel hands it on `swarm0` | **no**: any local or forwarded sender | only the IP header fields the queue needs (version, length, destination), bounds-checked |
| rtnetlink and nl80211 replies | kernel, trusted; still length-checked (`NLMSG_OK`, `RTA_OK`) | the netlink layer of the daemon |
| Command line and config file | the operator, trusted | the daemon's option parser; a bad value is a usage error, never a default |
| sysfs energy, gpsd location | the host, trusted for integrity, not for availability | the platform providers; a missing or malformed value is reported, not guessed |

## Privileges: the least it needs

| Needs | For | How it is limited |
|-------|-----|-------------------|
| `CAP_NET_ADMIN` | adding and deleting routes (rtnetlink), creating `swarm0` | the only capability; held as an ambient capability by an unprivileged user (a systemd unit with `CapabilityBoundingSet=CAP_NET_ADMIN`, `AmbientCapabilities=CAP_NET_ADMIN`, `NoNewPrivileges=yes`), never root. Where the operator creates `swarm0` beforehand (`ip tuntap add swarm0 mode tun user <user>`), only routes need it |
| an unprivileged UDP port | the control socket | a port above 1023, so no `CAP_NET_BIND_SERVICE` |
| read-only sysfs, the gpsd socket | energy and location providers | read only; no write anywhere outside the routing tables |

What it never does: run as root by design, spawn threads, `exec` another
program (no shelling out to `ip`), open a listening control socket for other
local users, or write files outside its configured state directory (none in
v0.x). Its routes carry the protocol number `RTPROT_SWARM` (88), and it adds,
changes and flushes only routes with that number, so it cannot clobber the
operator's static or other daemons' routes by mistake; on `SIGINT`/`SIGTERM`
(`signalfd`) it flushes those routes and exits.

## Threats

| Threat | In scope? | Defence |
|--------|-----------|---------|
| Malformed control message (truncated, oversized, wrong version) crashes or corrupts the daemon | **yes** | bounds-checked readers with a version byte and fuzz tests (org golden rule 3); a bad message is dropped and counted |
| Flood of control messages or TUN packets exhausts memory | **yes** | every queue, table and history has a configured cap (org golden rule 7); overflow drops and counts |
| Forged control messages from a host on the link inject or divert routes | **no**: the protocols carry no authentication, as in their papers | run it only on networks you control (SECURITY.md); a future authenticated mode would be its own epic |
| A compromised daemon rewrites the host's routes or interfaces | partly | the blast radius is `CAP_NET_ADMIN` and nothing more (above); systemd sandboxing narrows the rest |
| A local unprivileged user controls the daemon | **yes** | no control socket in v0.x; any later one is a Unix socket readable by its owner only |
| Timing side channels, physical access | no | out of scope for a research daemon |

## Emulators

Under Shadow and CORE/EMANE the daemon runs unmodified: one thread, all time
from `timerfd` through `IClock` (golden rule 13). Only Shadow makes a run
reproducible from its seed; CORE/EMANE runs on the wall clock (epic #3).

## Open questions

- Which kernel behaviours this model relies on (route protocol numbers,
  `RTA_MULTIPATH` weights, TUN with an unprivileged owner) are checked on a
  real kernel before the daemon relies on them: swarm-routing/.github#548.
- The packaged service unit and what it is safe for: swarm-routing/.github#267.

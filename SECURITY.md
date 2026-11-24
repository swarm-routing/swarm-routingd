# Security Policy

`swarm-routing/swarm-routingd` is a research routing daemon for Linux testbeds and emulators, pre-release (no version cut yet). This document records its
security posture honestly; it promises nothing the code does not do. The
org-wide policy is [swarm-routing/.github SECURITY.md](https://github.com/swarm-routing/.github/blob/main/SECURITY.md).

## Trust boundary

<!-- Which input is untrusted, the only code that parses it, and what that
code guarantees. A protocol: its wire-format decoder (org invariant 3). A
tool: the parsers of files it reads. If nothing parses untrusted input, say
so in one line. -->
Untrusted input, once the daemon exists (epic #3): every datagram on its UDP
control socket, every packet the kernel hands it on the `swarm0` TUN device,
and the netlink replies it reads. The only code that parses a control
message is the protocol core's bounds-checked little-endian reader (org
invariant 3), at the swarm-core release the build pins; the daemon copies
bytes into it and never interprets them. Today the repository holds a
skeleton that parses only its own command line. The full threat model, with
the capabilities the daemon holds and why: [docs/threat-model.md](docs/threat-model.md).

## Known, by-design limitations (out of scope)

- No authentication or integrity on control messages: any host on the
  routing interface can inject routes, as in the protocols' papers. Run it
  only on testbeds, emulators and networks you control.
- It needs `CAP_NET_ADMIN` (routes, TUN). It is meant to run with that one
  capability and nothing else (docs/threat-model.md); running it as root is
  the operator's choice and outside what it promises.
- Pre-release: nothing is built beyond a skeleton; no release exists yet.

<!-- org-sync:begin reporting -->
## Reporting a vulnerability

Report privately through GitHub's private vulnerability reporting: the
repository's **Security** tab, then **Report a vulnerability**. If that is
not available, open an issue that only asks for a private contact, and put
no vulnerability details in it. This is a research project maintained on a
best-effort basis: expect an acknowledgement within a few days, not an SLA.
<!-- org-sync:end reporting -->

## Verifying what it ships

No release exists yet. Releases will be built, signed and published by the
org's release workflow (`swarm-routing/.github` `reusable-release.yml`,
called by `.github/workflows/release.yml`): the source tarball
`swarm-routingd-X.Y.Z.tar.gz` (`make dist`), `SHA256SUMS`, a CycloneDX SBOM
and signed SLSA build provenance; the release notes carry the
`sha256sum -c` and `gh attestation verify` commands.

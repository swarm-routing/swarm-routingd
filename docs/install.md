# Install

swarm-routingd runs on Linux only (`epoll`, `timerfd`, `signalfd`,
rtnetlink, TUN). **No release exists yet** (epic #3 is in its first steps): what
installs today is the skeleton (#29), which answers `--version` and
`--help` and routes nothing. This page says how it will install, and what
works now.

## Supported distributions

| Distribution | Architectures | Compiler | CMake | Status |
|--------------|---------------|----------|-------|--------|
| Ubuntu 24.04 LTS | amd64, arm64 | GCC 13 | 3.28 | built and tested in CI (`build.yml`, amd64) |
| Debian 13 (trixie) | amd64, arm64 | GCC 14 | 3.31 | supported, not yet in CI |
| Raspberry Pi OS (Debian 13 based) | arm64 | GCC 14 | 3.31 | supported, not yet in CI (swarm-routing/.github#267) |
| Fedora 42 | x86_64, aarch64 | GCC 15 | 3.31 | supported, not yet in CI |

"Supported" means the toolchain meets the minimums below; a distribution
moves to "tested" when CI builds on it. The kernel features the daemon will
rely on are checked on a real kernel first (swarm-routing/.github#548); the
minimum kernel is set there, assumed 5.15 or newer until then.

## Required tools

| Tool | Minimum | Why |
|------|---------|-----|
| A C++23 compiler | GCC 13 or Clang 18 | the code is C++23 (the org's C++ standard) |
| CMake | 3.28 | the build |
| Ninja or GNU Make | any | the generator |
| git | 2.x | the source, and vcpkg's registries |
| curl, zip, unzip, tar, pkg-config | any | vcpkg's bootstrap and ports |
| vcpkg | a checkout from 2026 or later | the dependencies and the `swarm-routingd` port |
| iproute2 (`ip`) | any | to inspect the routes and the TUN device; the daemon itself never runs it |

Ubuntu 24.04 and Debian 13:

```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake ninja-build git curl zip unzip tar pkg-config iproute2
```

To develop (`make lint`, `make check`), also clang-format 18, the major CI
checks with; on Ubuntu 24.04 and Debian 13 (package `clang-format-18`):

```bash
sudo apt-get install -y clang-format-18
sudo ln -sf /usr/bin/clang-format-18 /usr/local/bin/clang-format
```

On Fedora 42, `sudo dnf install -y clang18-tools-extra`, which provides
`clang-format-18`; link it the same way. The symlink replaces any existing
`/usr/local/bin/clang-format`.

Fedora 42:

```bash
sudo dnf install -y gcc-c++ cmake ninja-build git curl zip unzip tar pkgconf-pkg-config iproute
```

## Through vcpkg

swarm-routing publishes its C++ ports in
[swarm-routing/vcpkg-registry](https://github.com/swarm-routing/vcpkg-registry):
`swarm-core` today, and `swarm-routingd` from the first release on (the
release workflow opens the port bump, `vcpkg-ports: swarm-routingd` in
`.github/workflows/release.yml`). Set up vcpkg once:

```bash
git clone https://github.com/microsoft/vcpkg "$HOME/vcpkg"
"$HOME/vcpkg/bootstrap-vcpkg.sh" -disableMetrics
export VCPKG_ROOT="$HOME/vcpkg"
```

Once the port exists, save a `vcpkg-configuration.json` in the vcpkg
instance root (`$VCPKG_ROOT/vcpkg-configuration.json`, where classic mode
reads it) that adds the org registry:

```json
{
  "default-registry": {
    "kind": "git",
    "repository": "https://github.com/microsoft/vcpkg",
    "baseline": "<a microsoft/vcpkg commit>"
  },
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/swarm-routing/vcpkg-registry",
      "baseline": "<a swarm-routing/vcpkg-registry commit>",
      "packages": ["swarm-core", "swarm-routingd"]
    }
  ]
}
```

and then, in classic mode, `"$VCPKG_ROOT/vcpkg" install swarm-routingd`,
which builds the release's source tarball and installs `sbin/swarm-routingd`
under the vcpkg installed tree. Verify what a release ships with the
commands in [SECURITY.md](../SECURITY.md) "Verifying what it ships".

## From source (works today)

swarm-core comes through vcpkg in manifest mode: with vcpkg set up as
above (`VCPKG_ROOT`), the configure step installs the swarm-core release
`vcpkg.json` pins, from swarm-routing/vcpkg-registry, into `build/`. No
`vcpkg-configuration.json` of your own is needed: the repository has one.

```bash
git clone https://github.com/swarm-routing/swarm-routingd.git
cd swarm-routingd
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
cmake --build build
ctest --test-dir build --output-on-failure
sudo cmake --install build   # /usr/local/sbin/swarm-routingd
swarm-routingd --version     # swarm-routingd 0.0.0 (swarm-core 2.1.0)
```

`make test` does the same, reading `$VCPKG_ROOT`. Without vcpkg, point
`CMAKE_PREFIX_PATH` at an installed swarm-core package instead.

## Running it

Not yet: the daemon is planned under epic #3. It will run as an unprivileged
user with `CAP_NET_ADMIN` only, never as root
([threat model](threat-model.md)).

## Known simulator bugs

<!-- org-sync:begin known-bugs -->
<!-- Generated from swarm-routing/sim-tools docs/ns3-bugs.md by swarm-routing/.github
     cmd/ns3-bugs (swarm-routing/.github#884); never edit by hand: a change goes to the register. -->
Upstream ns-3 defects our repositories meet, from the org's [ns-3 bug register](https://github.com/swarm-routing/sim-tools/blob/main/docs/ns3-bugs.md).
Each ID links its RCAPA (the reproduction, the root cause, the upstream report).

| ID | What breaks | ns-3 versions | Status | Our fix or workaround |
|----|-------------|---------------|--------|-----------------------|
| [NS3-001](https://github.com/swarm-routing/sim-tools/blob/main/docs/ns3-rcapa/ns3-rcapa-aodv-icmp-livelock.md) | AODV livelocks in a zero-time ICMP "net unreachable" storm | 3.49 and ns-3-dev `master` `8ec9b4a1` (run); not 3.48 | open upstream; reported, fix proposed (not ours); worked around | AODV-family arms on `ns3-dev:3.48` (AntHocNet CI) until the harness guard reaches them: `routing-bench` wraps the `aodv` arm in a guard ([swarm-routing/sim-tools#322](https://github.com/swarm-routing/sim-tools/pull/322)) applying [nsnam/ns-3-dev!3101](https://gitlab.com/nsnam/ns-3-dev/-/merge_requests/3101)'s rules (maintainer decision 2026-11-23, swarm-routing/sim-tools#238); strict XFAIL `3.49 sparse-aodv` in swarm-routing/sim-containers `test/known-failures.txt`; the patch `ns3/patches/NS3-001/` ([nsnam/ns-3-dev!3101](https://gitlab.com/nsnam/ns-3-dev/-/merge_requests/3101) at `d3fbcacb`; `apply.sh` applies it only to a source with the bug, [swarm-routing/sim-tools#378](https://github.com/swarm-routing/sim-tools/issues/378)), which the vcpkg `ns3` port applies by the same rule (maintainer decision 2026-11-25, [swarm-routing/vcpkg-registry#81](https://github.com/swarm-routing/vcpkg-registry/pull/81); its own copy until it takes the released asset, [swarm-routing/sim-tools#380](https://github.com/swarm-routing/sim-tools/issues/380)) |
| [NS3-002](https://github.com/swarm-routing/sim-tools/blob/main/docs/ns3-rcapa/ns3-rcapa-socket-map-heap-order.md) | AODV and DSDV order per-interface sockets by heap address | 3.42, 3.48, 3.49 and ns-3-dev `master` `8ec9b4a1`, `a150de8f` (run); 3.42, 3.48, 3.49 (read) | open upstream; reported; worked around | `--isolateArms` (default since v1.1.0); AntHocNet: its own maps ordered, stock `aodv` in its own process, the order gate on `anthocnet` rows only |
| [NS3-003](https://github.com/swarm-routing/sim-tools/blob/main/docs/ns3-rcapa/ns3-rcapa-dsdv-null-route.md) | DSDV sends on a route with a null output device (assert, or a silent SIGSEGV when optimized) | 3.36–3.48 and ns-3-dev 2026-08 (run); 3.49 (read) | open upstream; reported, fix proposed; worked around | AntHocNet's `isl-grid` refuses `dsdv` on multi-interface topologies, checked by its satellite arm smoke |
| [NS3-004](https://github.com/swarm-routing/sim-tools/blob/main/docs/ns3-rcapa/ns3-rcapa-aodv-hello-restart.md) | AODV never restarts its hello timer when an interface comes back up (a restarted node sends no HELLO for the rest of the run) | 3.49 and ns-3-dev `master` `8a06b457` (run); 3.49, `master` (read) | open upstream; draft ready | none: `--failures` is opt-in; `ns3/routing-bench/README.md` "Scripted failures" names the limit ([swarm-routing/sim-tools#361](https://github.com/swarm-routing/sim-tools/pull/361), open) |
| [NS3-005](https://github.com/swarm-routing/sim-tools/blob/main/docs/ns3-rcapa/ns3-rcapa-aodv-lifetime-overflow.md) | AODV route lifetime overflows int64 when an interface comes up after t=0 (`GetMaximumSimulationTime() + Now()`: UBSan aborts; undefined behaviour otherwise) | 3.49 and ns-3-dev `master` `d07400ba` (run); 3.7–3.49, `master` (read) | open upstream; reported; patch kept here and in the patched images | the patch `ns3/patches/NS3-005/` (`apply.sh` applies it only to a source with the bug), applied in swarm-routing/sim-containers `ns3-dev:3.49-{debug,sanitized}-patched-5c58dfa` (publish run 45712453689, the patch at sim-tools `1b36c739`); `--failures` AODV restarts ([swarm-routing/sim-tools#361](https://github.com/swarm-routing/sim-tools/pull/361)) abort on sanitized stock builds: the suite leaves them out where the source has the bug and runs them on the patched sanitized image (`ns3.yml` `failures-patched`) |

Fixed upstream, but present in an older ns-3 release you may still pin:

| What breaks | ns-3 versions | Fixed in | Our fix or workaround |
|-------------|---------------|----------|-----------------------|
| 802.11b HR/DSSS (5.5, 11 Mb/s) frames dropped as an unsupported modulation: `GetModulationClassForStandard(WIFI_STANDARD_80211b)` returns `WIFI_MOD_CLASS_DSSS`, and since 3.41 `WifiPhy::StartReceivePreamble` refuses any class above it | 3.42 (run); 3.41, 3.42 (read); not 3.40 or earlier (no gate, read) | 3.43 (`da9fcebe`) | strict XFAIL `3.41`/`3.42` `dsdv-manet`, `dense-{aodv,olsr,dsdv}` (`no-packets-delivered`) in swarm-routing/sim-containers `test/known-failures.txt` ([swarm-routing/sim-containers#250](https://github.com/swarm-routing/sim-containers/pull/250)); [swarm-routing/AntHocNet#923](https://github.com/swarm-routing/AntHocNet/issues/923) to check for 802.11b above 2 Mb/s on 3.42 |
| Four wifi unit suites (`wifi-txop`, `wifi-mlo`, `wifi-gcr`, `wifi-emlsr-basic-exchanges`) fail when `test-runner` is built without the `test` module: the tests match frames by packet UID, which needs packet metadata on, and 3.48 turns it on only through `src/test`'s `ns3tcp` suites (a test bug; `wifi-txop` then reads past its frame list) | 3.48 (run) | 3.49 (the tests use the MPDU's own UID) | strict XFAIL `3.48 unit:<suite>` in swarm-routing/sim-containers `test/known-failures.txt` |
<!-- org-sync:end known-bugs -->

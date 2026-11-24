# Install

swarm-routingd runs on Linux only (`epoll`, `timerfd`, `signalfd`,
rtnetlink, TUN). **No release exists yet** (epic #3 is deferred): what
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

Once the port exists, a `vcpkg-configuration.json` that adds the org
registry:

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

```bash
git clone https://github.com/swarm-routing/swarm-routingd.git
cd swarm-routingd
cmake -S . -B build -G Ninja
cmake --build build
ctest --test-dir build --output-on-failure
sudo cmake --install build   # /usr/local/sbin/swarm-routingd
swarm-routingd --version
```

When the daemon depends on swarm-core, the configure step takes the vcpkg
toolchain: `-DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"`.

## Running it

Not yet: the daemon is planned under epic #3. It will run as an unprivileged
user with `CAP_NET_ADMIN` only, never as root
([threat model](threat-model.md)).

# Developer guide

swarm-routingd is planned and deferred (swarm-routing/.github#672, org ROADMAP
decision 23): a C++23 CMake skeleton (#29) and the org's templates. This
guide says what runs today; each section grows with the code.

## Prerequisites

GNU Make, git, Python 3.11 or newer (the org tooling `make check` fetches),
CMake 3.28+, a C++23 compiler (GCC 13+ or Clang 18+), Ninja (optional),
clang-format 18 for `make lint`, and Docker for `make shell`. Per
distribution: [install.md](install.md).

## Get the code

```bash
git clone https://github.com/swarm-routing/swarm-routingd.git
cd swarm-routingd
```

No submodules or sibling checkouts are needed.

## Dependencies

swarm-core, through vcpkg in manifest mode (`vcpkg.json`,
`vcpkg-configuration.json`, `swarm-core.lock`; AGENTS.md "Dependencies").
Set up vcpkg once ([install.md](install.md) "Through vcpkg") and export
`VCPKG_ROOT`; `make build`/`test`/`dist` pass its toolchain to CMake, and the
first configure installs swarm-core into `build/vcpkg_installed`. `make check` fetches swarm-routing/.github's tooling into
`~/.cache/swarm-routing/dotgithub` (the licence-header gate and org-sync).

## Build

```bash
make build                      # cmake -S . -B build (vcpkg toolchain of $VCPKG_ROOT) && cmake --build build
make clean && CMAKE_GENERATOR=Ninja make build  # Ninja: a fresh build/, the generator is cached
```

## Test

`make test` builds and runs the ctest suite (`test/cli_test.cc` and the
binary's `--version`). `make check` is the gate: lint, test, licence
headers and the org-sync check, as CI runs them.

```bash
make check
```

## Run

```bash
./build/swarm-routingd --version
```

Only `--version` and `--help` work; the daemon is epic #3.

## Docker and dev containers

`make shell` opens a shell in the `ghcr.io/swarm-routing/ns3-dev` image
with this repository at `/src`. There is no `.devcontainer/`.

## Lint and format

`make lint` (clang-format on any C++ files) and `make format`. Licence
headers: `make headers`, the org's `check-headers` gate.

## CI map

| Workflow | What it checks | Required |
| --- | --- | --- |
| `build.yml` | `make lint`, then `make test` (the skeleton builds, its tests pass) | yes (`build`) |
| `release.yml` | the org release pipeline, on dispatch or a merged bump PR | no |
| `org-sync.yml` | the org-managed files match the pinned templates | yes (`check / org-sync`) |
| `licence.yml` | SPDX headers and the licence texts | yes (`headers / licence`) |
| `pr-title.yml` | the PR title is a lowercase Conventional Commit | yes (`title / title`) |
| `review-gate.yml` | CodeRabbit has reviewed the PR | yes (`review / coderabbit`) |
| `dco.yml` | an outside contributor signed off | no |
| `scorecard.yml`, `bestpractices-evidence.yml` | OpenSSF Scorecard; best-practices evidence | no |
| `settings-apply.yml`, `epics-changed.yml` | nudge the org's repo-settings and epic lists | no |

The required checks are the ones the `main` ruleset lists (`gh api
repos/swarm-routing/swarm-routingd/rules/branches/main`), applied from
`.github/org-sync.toml` `[settings]`.

## Release

Nothing is released yet, and nothing is until the maintainer re-plans epic
#3. A version is cut on request as
[CONTRIBUTING "Cutting a release"](https://github.com/swarm-routing/.github/blob/main/CONTRIBUTING.md#cutting-a-release)
says: `release.yml` (dispatch `dry-run`, then `bump`), against the ladder in
[roadmap.md](roadmap.md). The asset is `make dist`'s source tarball; the
release opens the `swarm-routingd` port bump in swarm-routing/vcpkg-registry
(`vcpkg-ports`), so the port must exist there first.

## Troubleshooting

- `make check` fails fetching the org tooling: it needs network access to
  github.com.

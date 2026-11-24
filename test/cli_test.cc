// Copyright (c) 2026 Daniel Joppi (https://github.com/swarm-routing)
// SPDX-License-Identifier: MIT OR GPL-2.0-only
//
// The skeleton's command line (#29). Plain asserts through a helper: no test
// framework until the daemon needs one.
#include "cli.h"

#include <array>
#include <iostream>
#include <sstream>
#include <string>
#include <string_view>

namespace {

int failures = 0;

void expect(bool ok, std::string_view what) {
  if (!ok) {
    std::cerr << "FAIL: " << what << '\n';
    ++failures;
  }
}

struct Result {
  int status;
  std::string out;
  std::string err;
};

template <std::size_t N>
Result run(const std::array<std::string_view, N> &args) {
  std::ostringstream out;
  std::ostringstream err;
  int status = swarm::routingd::run_cli(args, out, err);
  return {status, out.str(), err.str()};
}

} // namespace

int main() {
  using namespace std::string_literals;
  const std::string version{swarm::routingd::version()};

  auto v = run(std::array<std::string_view, 1>{"--version"});
  expect(v.status == 0, "--version exits 0");
  const std::string core{swarm::routingd::swarm_core_version()};
  expect(!core.empty(), "the build found a swarm-core version");
  expect(v.out == "swarm-routingd "s + version + " (swarm-core " + core + ")\n",
         "--version prints the name, VERSION and the swarm-core release");
  expect(v.err.empty(), "--version writes nothing to stderr");

  auto h = run(std::array<std::string_view, 1>{"--help"});
  expect(h.status == 0, "--help exits 0");
  expect(h.out.starts_with("usage: swarm-routingd"), "--help prints usage");

  auto none = run(std::array<std::string_view, 0>{});
  expect(none.status == 1, "no option exits 1 (no daemon yet)");
  expect(none.out.empty(), "no option writes nothing to stdout");

  auto bad = run(std::array<std::string_view, 1>{"--bogus"});
  expect(bad.status == 2, "an unknown option is a usage error");
  expect(bad.err.find("'--bogus'") != std::string::npos,
         "the error names the option");

  auto extra = run(std::array<std::string_view, 2>{"--version", "--help"});
  expect(extra.status == 2, "two options are a usage error");

  if (failures == 0) {
    std::cout << "cli_test: ok\n";
  }
  return failures == 0 ? 0 : 1;
}

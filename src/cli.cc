// Copyright (c) 2026 Daniel Joppi (https://github.com/swarm-routing)
// SPDX-License-Identifier: MIT OR GPL-2.0-only
#include "cli.h"

namespace swarm::routingd {

namespace {

constexpr std::string_view kUsage =
    "usage: swarm-routingd [--version | --help]\n"
    "\n"
    "The swarm-routing Linux routing daemon. Only the skeleton exists: it\n"
    "routes nothing yet (https://github.com/swarm-routing/swarm-routingd/"
    "issues/3).\n";

} // namespace

std::string_view version() { return SWARM_ROUTINGD_VERSION; }

int run_cli(std::span<const std::string_view> args, std::ostream &out,
            std::ostream &err) {
  if (args.size() == 1 && args[0] == "--version") {
    out << "swarm-routingd " << version() << '\n';
    return 0;
  }
  if (args.size() == 1 && (args[0] == "--help" || args[0] == "-h")) {
    out << kUsage;
    return 0;
  }
  if (args.empty()) {
    err << "swarm-routingd: the daemon is not built yet; only --version and "
           "--help work\n";
    return 1;
  }
  if (args.size() > 1) {
    err << "swarm-routingd: expected at most one option\n" << kUsage;
    return 2;
  }
  err << "swarm-routingd: unknown option '" << args[0] << "'\n" << kUsage;
  return 2;
}

} // namespace swarm::routingd

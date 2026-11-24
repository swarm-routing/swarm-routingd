// Copyright (c) 2026 Daniel Joppi (https://github.com/swarm-routing)
// SPDX-License-Identifier: MIT OR GPL-2.0-only
//
// The command line of the skeleton (#29): --version and --help. The daemon's
// options (interface, protocol, config file) arrive with epic #3.
#pragma once

#include <ostream>
#include <span>
#include <string_view>

namespace swarm::routingd {

// The version CMake reads from VERSION.
std::string_view version();

// Runs the command line `args` (without argv[0]); writes to `out` and `err`
// and returns the process exit status: 0 for --version and --help, 2 for a
// usage error, 1 when no option is given (the daemon itself is not built yet).
int run_cli(std::span<const std::string_view> args, std::ostream &out,
            std::ostream &err);

} // namespace swarm::routingd

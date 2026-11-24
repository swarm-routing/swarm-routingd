// Copyright (c) 2026 Daniel Joppi (https://github.com/swarm-routing)
// SPDX-License-Identifier: MIT OR GPL-2.0-only
#include "cli.h"

#include <iostream>
#include <string_view>
#include <vector>

int main(int argc, char **argv) {
  std::vector<std::string_view> args(argv + 1, argv + argc);
  return swarm::routingd::run_cli(args, std::cout, std::cerr);
}

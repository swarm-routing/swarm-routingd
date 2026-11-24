# Copyright (c) 2026 Daniel Joppi (https://github.com/swarm-routing)
# SPDX-License-Identifier: MIT OR GPL-2.0-only
#
# swarm-routingd: the skeleton (#29). It builds the binary and its test and
# holds no daemon logic yet; the reactor, the ports and the kernel sync land
# under epic #3.
#
# swarm-core comes from its vcpkg port (#31, swarm-routing/.github#489): with
# the vcpkg toolchain, vcpkg installs the version vcpkg.json pins from
# swarm-routing/vcpkg-registry at vcpkg-configuration.json's baseline
# (manifest mode), and find_package(swarm-core CONFIG REQUIRED) finds it:
#
#   cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
#
# Any installed swarm-core package works too (CMAKE_PREFIX_PATH).
cmake_minimum_required(VERSION 3.28)

file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION" SWARM_ROUTINGD_VERSION LIMIT_COUNT 1)
project(swarm-routingd VERSION ${SWARM_ROUTINGD_VERSION} LANGUAGES CXX)

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
  message(FATAL_ERROR "swarm-routingd runs on Linux only (epoll, timerfd, signalfd, rtnetlink, TUN)")
endif()

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(SWARM_ROUTINGD_BUILD_TESTS "Build the tests" ON)

# The ports and primitives the daemon hosts the protocol cores on
# (golden rule 10: the cores decide, the daemon carries out). The version is
# vcpkg.json's override, the release swarm-core.lock names.
find_package(swarm-core CONFIG REQUIRED)

add_library(swarm_routingd_cli STATIC src/cli.cc)
target_include_directories(swarm_routingd_cli PUBLIC src)
target_compile_definitions(swarm_routingd_cli PRIVATE
  SWARM_ROUTINGD_VERSION="${PROJECT_VERSION}"
  SWARM_ROUTINGD_SWARM_CORE_VERSION="${swarm-core_VERSION}")
target_link_libraries(swarm_routingd_cli PUBLIC swarm::core)
target_compile_options(swarm_routingd_cli PRIVATE -Wall -Wextra -Wpedantic -Werror)

add_executable(swarm-routingd src/main.cc)
target_link_libraries(swarm-routingd PRIVATE swarm_routingd_cli)
target_compile_options(swarm-routingd PRIVATE -Wall -Wextra -Wpedantic -Werror)

include(GNUInstallDirs)
install(TARGETS swarm-routingd RUNTIME DESTINATION ${CMAKE_INSTALL_SBINDIR})

if(SWARM_ROUTINGD_BUILD_TESTS)
  enable_testing()
  add_executable(cli_test test/cli_test.cc)
  target_link_libraries(cli_test PRIVATE swarm_routingd_cli)
  target_compile_options(cli_test PRIVATE -Wall -Wextra -Wpedantic -Werror)
  add_test(NAME cli COMMAND cli_test)
  add_test(NAME binary-version COMMAND swarm-routingd --version)
  set_tests_properties(binary-version PROPERTIES
    PASS_REGULAR_EXPRESSION "^swarm-routingd ${PROJECT_VERSION} \\(swarm-core ${swarm-core_VERSION}\\)\n$")
  add_test(NAME binary-bad-option COMMAND swarm-routingd --no-such-option)
  set_tests_properties(binary-bad-option PROPERTIES WILL_FAIL TRUE)
endif()

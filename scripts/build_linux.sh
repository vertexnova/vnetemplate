#!/bin/bash

#==============================================================================
# VneTemplate Linux Build Script
#==============================================================================
# Copyright (c) 2026 Ajeet Singh Yadav. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License")
#
# Author:    Ajeet Singh Yadav
# Created:   February 2026
#
# Minimal: configure, build, test. Supports gcc and clang.
#==============================================================================

set -e

JOBS=10
ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -j|--jobs) [[ -n "$2" && "$2" =~ ^[0-9]+$ ]] && { JOBS="$2"; shift 2; } || { echo "Invalid jobs: $2"; exit 1; } ;;
        -j*) JOBS="${1#-j}"; [[ "$JOBS" =~ ^[0-9]+$ ]] || { echo "Invalid jobs: $JOBS"; exit 1; }; shift ;;
        *) ARGS+=("$1"); shift ;;
    esac
done
set -- "${ARGS[@]}"

usage() {
  echo "Usage: $0 [-t <build_type>] [-a <action>] [-clean] [-j <jobs>] [-gcc|-clang]"
  echo "  -t <build_type>  Debug|Release|RelWithDebInfo|MinSizeRel"
  echo "  -a <action>      configure|build|configure_and_build|test"
  echo "  -clean           Clean build directory first"
  echo "  -j <jobs>        Parallel jobs (default: 10)"
  echo "  -gcc             Use GCC (default if available)"
  echo "  -clang           Use Clang"
  exit 1
}

BUILD_TYPE="Debug"
ACTION="configure_and_build"
CLEAN_BUILD=false
C_COMPILER=""
CXX_COMPILER=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--build-type) BUILD_TYPE="$2"; shift 2 ;;
    -a|--action) ACTION="$2"; shift 2 ;;
    -clean|--clean) CLEAN_BUILD=true; shift ;;
    -j|--jobs) JOBS="$2"; shift 2 ;;
    -gcc) C_COMPILER="gcc"; CXX_COMPILER="g++"; shift ;;
    -clang) C_COMPILER="clang"; CXX_COMPILER="clang++"; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

# Default to gcc if not specified
if [[ -z "$C_COMPILER" ]]; then
  if command -v gcc &>/dev/null && command -v g++ &>/dev/null; then
    C_COMPILER="gcc"
    CXX_COMPILER="g++"
  elif command -v clang &>/dev/null && command -v clang++ &>/dev/null; then
    C_COMPILER="clang"
    CXX_COMPILER="clang++"
  else
    echo "No suitable compiler found (gcc or clang required)"
    exit 1
  fi
fi

COMPILER_VERSION=$("$CXX_COMPILER" --version 2>/dev/null | head -n 1 | awk '{print $NF}' | sed 's/(.*)//' | tr -d ' ' || true)
[[ -z "$COMPILER_VERSION" ]] && COMPILER_VERSION=$("$CXX_COMPILER" --version 2>/dev/null | head -n 1 | awk '{print $3}' || echo "unknown")

echo "Linux :: $CXX_COMPILER-${COMPILER_VERSION}"
PROJECT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

BUILD_DIR="$PROJECT_ROOT/build/${BUILD_TYPE}/build-linux-${CXX_COMPILER}-${COMPILER_VERSION}"
CMAKE_EXTRA=""
if [[ -n "$C_COMPILER" ]]; then
  CMAKE_EXTRA="-DCMAKE_C_COMPILER=$C_COMPILER -DCMAKE_CXX_COMPILER=$CXX_COMPILER"
fi
CONFIGURE_CMD="cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE $CMAKE_EXTRA -DBUILD_TESTS=ON $PROJECT_ROOT"
BUILD_CMD="make -j$JOBS"
TEST_CMD="ctest --output-on-failure"

clean_build() { rm -rf "$BUILD_DIR"; mkdir -p "$BUILD_DIR"; cd "$BUILD_DIR" || exit; }
ensure_build_dir() { [ ! -d "$BUILD_DIR" ] && mkdir -p "$BUILD_DIR"; cd "$BUILD_DIR" || exit; }

case $ACTION in
  configure) [ "$CLEAN_BUILD" = true ] && clean_build || ensure_build_dir; eval $CONFIGURE_CMD ;;
  build) [ "$CLEAN_BUILD" = true ] && clean_build || ensure_build_dir; eval $CONFIGURE_CMD; eval $BUILD_CMD ;;
  configure_and_build) [ "$CLEAN_BUILD" = true ] && clean_build || ensure_build_dir; eval $CONFIGURE_CMD; eval $BUILD_CMD ;;
  test) [ "$CLEAN_BUILD" = true ] && clean_build || ensure_build_dir; eval $CONFIGURE_CMD; eval $BUILD_CMD; eval $TEST_CMD ;;
  *) usage ;;
esac

echo ""
echo "=== Build completed successfully ==="
echo "Build directory: $BUILD_DIR"

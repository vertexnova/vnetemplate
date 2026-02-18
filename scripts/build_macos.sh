#!/bin/bash

#==============================================================================
# VneTemplate macOS Build Script
#==============================================================================
# Copyright (c) 2026 Ajeet Singh Yadav. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License")
#
# Author:    Ajeet Singh Yadav
# Created:   February 2026
#
# Minimal: configure, build, test. Optional -xcode for Xcode project.
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
  echo "Usage: $0 [-t <build_type>] [-a <action>] [-clean] [-j <jobs>] [-xcode]"
  echo "  -t <build_type>  Debug|Release|RelWithDebInfo|MinSizeRel"
  echo "  -a <action>      configure|build|configure_and_build|test"
  echo "  -clean           Clean build directory first"
  echo "  -j <jobs>        Parallel jobs (default: 10)"
  echo "  -xcode           Generate Xcode project instead of Makefiles"
  exit 1
}

BUILD_TYPE="Debug"
ACTION="configure_and_build"
CLEAN_BUILD=false
GENERATE_XCODE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--build-type) BUILD_TYPE="$2"; shift 2 ;;
    -a|--action) ACTION="$2"; shift 2 ;;
    -clean|--clean) CLEAN_BUILD=true; shift ;;
    -xcode|--xcode) GENERATE_XCODE=true; shift ;;
    -j|--jobs) JOBS="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

COMPILER_VERSION=$(clang --version 2>/dev/null | head -n 1 | awk '{print $4}' | sed 's/(.*)//' || true)
[[ -z "$COMPILER_VERSION" || "$COMPILER_VERSION" = "version" ]] && COMPILER_VERSION=$(clang --version 2>/dev/null | head -n 1 | awk '{print $3}' || echo "unknown")

echo "macOS :: clang-${COMPILER_VERSION}"
PROJECT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

if [ "$GENERATE_XCODE" = true ]; then
  BUILD_DIR="$PROJECT_ROOT/build/${BUILD_TYPE}/xcode-macos-clang-${COMPILER_VERSION}"
  CONFIGURE_CMD="cmake -G Xcode -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 -DBUILD_TESTS=ON $PROJECT_ROOT"
  BUILD_CMD="xcodebuild -project vnetemplate.xcodeproj -configuration $BUILD_TYPE -parallelizeTargets -jobs $JOBS"
  TEST_CMD="xcodebuild -project vnetemplate.xcodeproj -configuration $BUILD_TYPE -target RUN_TESTS"
else
  BUILD_DIR="$PROJECT_ROOT/build/${BUILD_TYPE}/build-macos-clang-${COMPILER_VERSION}"
  CONFIGURE_CMD="cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 -DBUILD_TESTS=ON $PROJECT_ROOT"
  BUILD_CMD="make -j$JOBS"
  TEST_CMD="ctest --output-on-failure"
fi

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

#!/bin/bash

#==============================================================================
# VneTemplate clang-format Script
#==============================================================================
# Copyright (c) 2026 Ajeet Singh Yadav. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License")
#
# Author:    Ajeet Singh Yadav
# Created:   February 2026
#
# Format C/C++ sources with clang-format. Use -check to only verify (CI).
#==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

CHECK_ONLY=false
while [[ $# -gt 0 ]]; do
  case $1 in
    -check|--check) CHECK_ONLY=true; shift ;;
    -h|--help)
      echo "Usage: $0 [-check]"
      echo "  -check   Only check formatting (exit non-zero if changes needed); used in CI"
      echo "  (no arg) Format files in place"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if ! command -v clang-format &>/dev/null; then
  echo "clang-format not found. Install clang-format (e.g. clang-format or llvm package)."
  exit 1
fi

# Sources and headers under src, include, tests; exclude third-party/build
SOURCES=$(find "$PROJECT_ROOT" -type f \( -name "*.cpp" -o -name "*.c" -o -name "*.h" -o -name "*.hpp" \) \
  -not -path "*/build/*" \
  -not -path "*/_deps/*" \
  -not -path "*/deps/*" \
  2>/dev/null || true)

if [[ -z "$SOURCES" ]]; then
  echo "No C/C++ sources found to format."
  exit 0
fi

if [[ "$CHECK_ONLY" == true ]]; then
  UNFORMATTED=""
  for f in $SOURCES; do
    TMP=$(mktemp)
    clang-format "$f" > "$TMP"
    if ! diff -q "$f" "$TMP" &>/dev/null; then
      UNFORMATTED="$UNFORMATTED $f"
    fi
    rm -f "$TMP"
  done
  if [[ -n "$UNFORMATTED" ]]; then
    echo "The following files are not formatted (run scripts/format.sh to fix):"
    echo "$UNFORMATTED"
    exit 1
  fi
  echo "Format check passed."
  exit 0
fi

echo "Formatting C/C++ sources..."
for f in $SOURCES; do
  clang-format -i "$f"
done
echo "Done."

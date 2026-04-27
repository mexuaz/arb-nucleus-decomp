#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_TARGET="//benchmarks/NucleusDecomposition:NucleusDecomposition_main"
BAZEL_VERSION="${BAZEL_VERSION:-2.1.0}"
BAZELISK_VERSION="${BAZELISK_VERSION:-1.20.0}"
LOCAL_BIN_DIR="${LOCAL_BIN_DIR:-$HOME/.local/bin}"
BAZELISK_BIN="$LOCAL_BIN_DIR/bazelisk"

load_first_module() {
  local module_name
  for module_name in "$@"; do
    if module load "$module_name" >/dev/null 2>&1; then
      return 0
    fi
  done
  return 1
}

if command -v module >/dev/null 2>&1; then
  module purge || true
  module spider bazel || true
  module spider gcc || true
  load_first_module stdenv/2023 StdEnv/2023 StdEnv/2020 || true
  load_first_module gcc/12.3.0 gcc/11.4.0 gcc/10.3.0 gcc || true
fi

if command -v bazel >/dev/null 2>&1; then
  BAZEL_CMD="$(command -v bazel)"
else
  mkdir -p "$LOCAL_BIN_DIR"
  if [[ ! -x "$BAZELISK_BIN" ]]; then
    curl -L --fail -o "$BAZELISK_BIN" \
      "https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-linux-amd64"
    chmod +x "$BAZELISK_BIN"
  fi
  BAZEL_CMD="$BAZELISK_BIN"
  export USE_BAZEL_VERSION="$BAZEL_VERSION"
fi

cd "$REPO_ROOT"
"$BAZEL_CMD" build "$BUILD_TARGET" "$@"

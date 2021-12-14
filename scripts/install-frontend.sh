#!/bin/bash
set -e

function fail() {
  >&2 echo "Error: $@"
  exit 1
}

command -v npm &>/dev/null || fail "npm command not found; did you install Node.js?"

set -x

cd assets
npm ci

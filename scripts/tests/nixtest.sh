#!/bin/bash
# ~/nixtest.sh
# ------------
# Copyright (C) 2025 Qompass AI, All rights reserved

features=(
  "auto-allocate-uids"
  "ca-derivations"
  "cgroups"
  "daemon-trust-override"
  "dynamic-derivations"
  "fetch-closure"
  "flakes"
  "nix-command"
  "no-url-literals"
  "pipe-operators"
  "repl-flake"
)

for feature in "${features[@]}"; do
  if nix --extra-experimental-features "$feature" --help &>/dev/null; then
    echo "✅ $feature - VALID"
  else
    echo "❌ $feature - INVALID or not available"
  fi
done

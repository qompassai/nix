#!/bin/bash
# /qompassai/nix/scripts/tests/nktest.sh
# Qompass AI Nix Key Test Script
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
keys=(
  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
  "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
  "cuda-maintainers.cachix.org-1:0dq3bujKpuEPiCIS3u6dElBNvAOSHTFgPxFUPtHV0Bk="
  "cache.iog.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
)
for key in "${keys[@]}"; do
  echo "Testing key: $key"
  cat >/tmp/test-nix.conf <<EOF
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= $key
EOF
  if NIX_CONFIG="$(cat /tmp/test-nix.conf)" nix --version >/dev/null 2>&1; then
    echo "✅ Valid: $key"
  else
    echo "❌ Invalid: $key"
  fi
done
rm -f /tmp/test-nix.conf

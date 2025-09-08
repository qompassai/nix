#!/usr/bin/env bash
# Qompass AI Flakehub Publish Script
# Copyright (C) 2025 Qompass AI, All rights reserved
#####################################################
BASE_DIR="${HOME}/.GH/Qompass"
cd "$BASE_DIR" || {
    echo "Directory not found: $BASE_DIR"
    exit 1
}
for repo in */; do
    clean_repo=${repo%/}
    echo "Processing $clean_repo..."
    cd "$clean_repo" || {
        echo "Failed to enter $clean_repo"
        continue
    }
    if [ -f flake.nix ]; then
        echo "Skipping $clean_repo (flake.nix exists)"
        cd ..
        continue
    fi
    NIX_CONFIG="experimental-features = nix-command flakes" \
        nix run github:DeterminateSystems/fh -- init \
        "qompassai/$clean_repo" || {
        echo "fh init failed"
        cd ..
        continue
    }
    sed -i $'s|supportedSystems = \["x86_64-linux"\];|supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];|g' flake.nix
    sed -i 's|system = "x86_64-linux";|inherit system;|g' flake.nix
    if ! grep -q 'aarch64-darwin' flake.nix; then
        echo "Error: Failed to add multi-arch support to $clean_repo"
        cd ..
        continue
    fi
    mkdir -p .github/workflows
    cat >.github/workflows/fh.yml <<EOF
name: Publish to FlakeHub

on:
  push:
    branches: [main]

jobs:
  flakehub-publish:
    strategy:
      matrix:
        system: [x86_64-linux, aarch64-linux, aarch64-darwin]
    runs-on: [self-hosted, linux, x64, \${{ matrix.system }}]
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: DeterminateSystems/nix-installer-action@main
      - uses: DeterminateSystems/flakehub-push@main
        with:
          name: qompassai/$clean_repo
          rolling: true
          visibility: public
          system: \${{ matrix.system }}
EOF

    git add -f flake.nix .github/workflows/fh.yml
    git commit -m "Add cross-architecture FlakeHub support" || echo "No changes to commit"
    git push origin main || echo "Push failed (possibly no changes)"

    cd ..
done

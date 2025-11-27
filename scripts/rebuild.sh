#!/bin/sh
# /qompassai/nix/scripts/rebuild.sh
# Qompass AI Nix Rebuild Script
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
red() {
    printf '\033[31m[!] %s \033[0m\n' "$1"
    if [ -n "${2:-}" ]; then
        eval_val=$(eval "$2")
        printf '\033[31m[!] %s \033[0m\n' "$eval_val"
    fi
}
green() {
    printf '\033[32m[+] %s \033[0m\n' "$1"
    if [ -n "${2:-}" ]; then
        eval_val=$(eval "$2")
        printf '\033[32m[+] %s \033[0m\n' "$eval_val"
    fi
}
yellow() {
    printf '\033[33m[*] %s \033[0m\n' "$1"
    if [ -n "${2:-}" ]; then
        eval_val=$(eval "$2")
        printf '\033[33m[*] %s \033[0m\n' "$eval_val"
    fi
}
switch_args="--show-trace --impure --flake "
if [ $# -ge 1 ] && [ "$1" = "trace" ]; then
    switch_args="$switch_args --show-trace "
elif [ $# -ge 1 ]; then
    HOST=$1
else
    HOST=$(hostname)
fi
switch_args="$switch_args .#$HOST switch"
os=$(uname -s)
REBUILD_SUCCESS=0
if [ "$os" = "Darwin" ]; then
    mkdir -p "$HOME/.config/nix" 2>/dev/null
    CONF="$HOME/.config/nix/nix.conf"
    if [ ! -f "$CONF" ]; then
        printf 'experimental-features = nix-command flakes\n' >"$CONF"
    fi
    if ! command -v git >/dev/null 2>&1; then
        echo "Installing xcode tools"
        xcode-select --install
    fi
    if [ ! -e /opt/homebrew/bin/brew ]; then
        echo "Installing rosetta"
        softwareupdate --install-rosetta --agree-to-license
        echo "Installing homebrew"
        NONINTERACTIVE=1
        export NONINTERACTIVE
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
    green "====== REBUILD ======"
    if ! command -v darwin-rebuild >/dev/null 2>&1; then
        nix build --show-trace .#darwinConfigurations."$HOST".system
        if ./result/sw/bin/darwin-rebuild "$switch_args"; then
            REBUILD_SUCCESS=1
        fi
    else
        echo "$switch_args"
        if darwin-rebuild "$switch_args"; then
            REBUILD_SUCCESS=1
        fi
    fi
else
    green "====== REBUILD ======"
    if command -v nh >/dev/null 2>&1; then
        REPO_PATH=$(pwd)
        export REPO_PATH
        if nh os switch . -- --impure --show-trace; then
            REBUILD_SUCCESS=1
        fi
    else
        if sudo nixos-rebuild "$switch_args"; then
            REBUILD_SUCCESS=1
        fi
    fi
fi

if [ "$REBUILD_SUCCESS" -eq 1 ]; then
    green "====== POST-REBUILD ======"
    green "Rebuilt successfully"
    if git diff --exit-code >/dev/null 2>&1 && git diff --staged --exit-code >/dev/null 2>&1; then
        # If the current commit is tagged as buildable, say so; else, tag it
        if git tag --points-at HEAD | grep -q buildable; then
            yellow "Current commit is already tagged as buildable"
        else
            tag_name="buildable-$(date +%Y%m%d%H%M%S)"
            git tag "$tag_name" -m ''
            green "Tagged current commit as buildable"
        fi
    else
        yellow "WARN: There are pending changes that would affect the build succeeding. Commit them before tagging"
    fi
fi

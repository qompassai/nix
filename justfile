# justfile
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
SOPS_FILE := "../nix-secrets/.sops.yaml"
export HELPERS_PATH := justfile_directory() + "/scripts/helpers.sh"
default:
  @just --list
rebuild-pre: update-nix-secrets
  @git add --intent-to-add .
rebuild-post: check-sops
check ARGS="":
	NIXPKGS_ALLOW_UNFREE=1 REPO_PATH=$(pwd) nix flake check --impure --keep-going --show-trace {{ARGS}}
	cd nixos-installer && NIXPKGS_ALLOW_UNFREE=1 REPO_PATH=$(pwd) nix flake check --impure --keep-going --show-trace {{ARGS}}
rebuild: rebuild-pre && rebuild-post
  # NOTE: Add --option eval-cache false if you end up caching a failure you can't get around
  scripts/rebuild.sh
rebuild-full: rebuild-pre && rebuild-post
  scripts/rebuild.sh
  just check
rebuild-trace: rebuild-pre && rebuild-post
  scripts/rebuild.sh trace
  just check
update:
  nix flake update
rebuild-update: update rebuild
diff:
  git diff ':!flake.lock'
age-key:
  nix-shell -p age --run "age-keygen"
check-sops:
  scripts/check-sops.sh
update-nix-secrets:
  @(cd ../nix-secrets && git fetch && git rebase > /dev/null) || true
  nix flake update nix-secrets --timeout 5
iso:
  # If we dont remove this folder, libvirtd VM doesnt run with the new iso...
  rm -rf result
  nix build --impure .#nixosConfigurations.iso.config.system.build.isoImage && ln -sf result/iso/*.iso latest.iso
iso-install DRIVE: iso
  sudo dd if=$(eza --sort changed result/iso/*.iso | tail -n1) of={{DRIVE}} bs=4M status=progress oflag=sync
disko DRIVE PASSWORD:
  echo "{{PASSWORD}}" > /tmp/disko-password
  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
    --mode disko \
    disks/btrfs-luks-impermanence-disko.nix \
    --arg disk '"{{DRIVE}}"' \
    --arg password '"{{PASSWORD}}"'
  rm /tmp/disko-password
sync USER HOST PATH:
	rsync -av --filter=':- .gitignore' -e "ssh -l {{USER}} -oport=22" . {{USER}}@{{HOST}}:{{PATH}}/nix-config
build-host HOST:
	NIX_SSHOPTS="-p22" nixos-rebuild --target-host {{HOST}} --use-remote-sudo --show-trace --impure --flake .#"{{HOST}}" switch
sops-rekey:
  cd ../nix-secrets && for file in $(ls sops/*.yaml); do \
    sops updatekeys -y $file; \
  done
rekey: sops-rekey
  cd ../nix-secrets && \
    (pre-commit run --all-files || true) && \
    git add -u && (git commit -nm "chore: rekey" || true) && git push
sops-update-age-key FIELD KEYNAME KEY:
    #!/usr/bin/env bash
    source {{HELPERS_PATH}}
    sops_update_age_key {{FIELD}} {{KEYNAME}} {{KEY}}
sops-update-user-age-key USER HOST KEY:
  just sops-update-age-key users {{USER}}_{{HOST}} {{KEY}}
sops-update-host-age-key HOST KEY:
  just sops-update-age-key hosts {{HOST}} {{KEY}}
sops-add-host-creation-rules USER HOST:
    #!/usr/bin/env bash
    source {{HELPERS_PATH}}
    sops_add_host_creation_rules "{{USER}}" "{{HOST}}"
sops-add-shared-creation-rules USER HOST:
    #!/usr/bin/env bash
    source {{HELPERS_PATH}}
    sops_add_shared_creation_rules "{{USER}}" "{{HOST}}"
sops-add-creation-rules USER HOST:
    just sops-add-host-creation-rules {{USER}} {{HOST}} && \
    just sops-add-shared-creation-rules {{USER}} {{HOST}}

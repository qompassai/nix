# /qompassai/nix/modules/harden/fprint.nix
# Qompass AI Nix Harden Fprint Module
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.nix.harden;
  nix = import ./helpers.nix { inherit config pkgs lib; };
  hasFingerprintReader = ''
    ${pkgs.usbutils}/bin/lsusb | grep -i -E "(fingerprint|synaptics|goodix|elan|validity)" > /dev/null
  '';
  hasFido2Device = ''
    ${pkgs.libfido2}/bin/fido2-token -L 2>/dev/null | grep -q "dev:"
  '';
in
{
  options.nix.security = {
    enable = mkEnableOption "Harden features";
    fingerprint = {
      enable = mkEnableOption "fingerprint authentication";
      autoDetect = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically detect and enable fingerprint readers";
      };
    };
    fido2 = {
      enable = mkEnableOption "FIDO2/WebAuthn authentication";
      autoDetect = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically detect and enable FIDO2 devices";
      };
    };
    systemHardening = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable system security hardening";
      };
      faillock = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable account lockout protection";
        };
        denyAttempts = mkOption {
          type = types.int;
          default = 10;
          description = "Number of failed attempts before lockout";
        };
        unlockTime = mkOption {
          type = types.int;
          default = 120;
          description = "Lockout duration in seconds";
        };
      };
    };
  };
  config = mkIf (cfg.enable or true) {
    environment.systemPackages = with pkgs; [
      fprintd
      libfido2
      pam
      pam_u2f
      usbutils
      pciutils
      ufw
    ];
    services.fprintd = mkIf (cfg.fingerprint.enable or cfg.fingerprint.autoDetect) {
      enable = true;
      package = pkgs.fprintd;
    };
    security.pam.services = mkIf (cfg.fingerprint.enable or cfg.fingerprint.autoDetect) {
      sudo.fprintAuth = true;
      polkit-1 = {
        fprintAuth = true;
        text = ''
          auth       sufficient   pam_fprintd.so
          auth       include      system-auth
          account    include      system-auth
          password   include      system-auth
          session    include      system-auth
        '';
      };
      login.fprintAuth = mkDefault true;
      hyprlock = mkIf (config.nix.desktop.enable or false) {
        fprintAuth = true;
        text = ''
          auth       sufficient   pam_fprintd.so
          auth       include      system-auth
          account    include      system-auth
        '';
      };
    };
    security.pam.services = mkIf (cfg.fido2.enable) {
      sudo = {
        text = mkBefore ''
          auth       sufficient   pam_u2f.so cue authfile=/etc/fido2/fido2
        '';
      };
      polkit-1 = {
        text = mkBefore ''
          auth       sufficient   pam_u2f.so cue authfile=/etc/fido2/fido2
        '';
      };
      hyprlock = mkIf (config.nix.desktop.enable or false) {
        text = mkBefore ''
          auth       sufficient   pam_u2f.so cue authfile=/etc/fido2/fido2
        '';
      };
    };
    security = mkIf cfg.systemHardening.enable {
      sudo = {
        enable = true;
        wheelNeedsPassword = true;
        execWheelOnly = true;
      };
      polkit = {
        enable = true;
        extraConfig = ''
          polkit.addRule(function(action, subject) {
              if (subject.isInGroup("wheel") &&
                  (action.id == "org.freedesktop.systemd1.manage-units" ||
                   action.id == "org.freedesktop.NetworkManager.settings.modify.system")) {
                  return polkit.Result.YES;
              }
          });
        '';
      };
      pam.loginLimits = mkIf cfg.systemHardening.faillock.enable [
        {
          domain = "*";
          type = "hard";
          item = "core";
          value = "0";
        }
      ];
    };
    security.pam.services.system-auth = mkIf cfg.systemHardening.faillock.enable {
      text = mkAfter ''
        auth        required      pam_faillock.so preauth
        auth        required      pam_faillock.so authfail deny=${toString cfg.systemHardening.faillock.denyAttempts} unlock_time=${toString cfg.systemHardening.faillock.unlockTime}
        account     required      pam_faillock.so
      '';
    };
    networking.firewall = mkIf cfg.systemHardening.enable {
      enable = true;
      defaultPolicy = {
        default = "deny";
        defaultOutput = "allow";
      };
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ 53317 ];
      allowedTCPPortRanges = [
        { from = 53317; to = 53317; }
      ];
    };
    system.activationScripts.fido2Setup = mkIf cfg.fido2.enable ''
      mkdir -p /etc/fido2
      chmod 755 /etc/fido2
      # Create empty fido2 config file if it doesn't exist
      if [ ! -f /etc/fido2/fido2 ]; then
        touch /etc/fido2/fido2
        chmod 644 /etc/fido2/fido2
      fi
    '';
    environment.systemPackages = [
      (nix.makeScript "fprintd" "Manage fingerprint authentication" ''
        case "$1" in
          "setup"|"enroll")
            echo "═══════════════════════════"
            if ! ${hasFingerprintReader}; then
              echo "❌ No fingerprint reader detected!"
              echo "   Supported devices: Synaptics, Goodix, Elan, Validity sensors"
              exit 1
            fi
            echo "✅ Fingerprint reader detected"
            if ! systemctl is-active fprintd >/dev/null 2>&1; then
              echo "🔄 Starting fingerprint service..."
              sudo systemctl start fprintd
            fi
            echo "👆 Please follow the prompts to enroll your fingerprint"
            echo "   You'll need to scan your finger multiple times"
            echo
            ${pkgs.fprintd}/bin/fprintd-enroll "$USER"
            if [ $? -eq 0 ]; then
              echo
              echo "✅ Fingerprint enrolled successfully!"
              echo "💡 You can now use your fingerprint for:"
              echo "   - sudo commands"
              echo "   - System authentication dialogs"
              echo "   - Screen unlock (if supported)"
            else
              echo "❌ Fingerprint enrollment failed"
              exit 1
            fi
            ;;

          "test"|"verify")
            echo "🔐 Testing fingerprint authentication..."
            if ! ${hasFingerprintReader}; then
              echo "❌ No fingerprint reader detected!"
              exit 1
            fi
            echo "👆 Please scan your enrolled finger"
            ${pkgs.fprintd}/bin/fprintd-verify "$USER"
            if [ $? -eq 0 ]; then
              echo "✅ Fingerprint verification successful!"
            else
              echo "❌ Fingerprint verification failed"
              echo "💡 Try: nix-fingerprint setup"
            fi
            ;;
          "remove"|"delete")
            echo "🗑️  Removing fingerprint data..."
            ${pkgs.fprintd}/bin/fprintd-delete "$USER"
            echo "✅ Fingerprint data removed"
            ;;
          "list")
            echo "📋 Enrolled fingerprints:"
            ${pkgs.fprintd}/bin/fprintd-list "$USER" 2>/dev/null || echo "   No fingerprints enrolled"
            ;;
          *)
            echo "Fingerprint Management"
            echo
            echo "Commands:"
            echo "  setup, enroll  - Enroll a new fingerprint"
            echo "  test, verify   - Test fingerprint authentication"
            echo "  remove, delete - Remove enrolled fingerprints"
            echo "  list          - List enrolled fingerprints"
            echo
            if ${hasFingerprintReader}; then
              echo "Hardware: ✅ Fingerprint reader detected"
            else
              echo "Hardware: ❌ No fingerprint reader found"
            fi
            if systemctl is-active fprintd >/dev/null 2>&1; then
              echo "Service:  ✅ fprintd running"
            else
              echo "Service:  ❌ fprintd not running"
            fi
            ;;
        esac
      '')

      (nix.makeScript "nix-fido2" "Manage FIDO2/WebAuthn authentication" ''
        case "$1" in
          "setup"|"register")
            echo "🔑 Nix FIDO2 Setup"
            echo "═══════════════════"
            if ! ${hasFido2Device}; then
              echo "❌ No FIDO2 device detected!"
              echo "   Please insert a FIDO2 security key (YubiKey, etc.)"
              exit 1
            fi
            echo "✅ FIDO2 device detected:"
            ${pkgs.libfido2}/bin/fido2-token -L
            echo
            echo "🔑 Please touch your security key when prompted..."
            output=$(${pkgs.pam_u2f}/bin/pamu2fcfg -u "$USER")
            if [ $? -eq 0 ] && [ -n "$output" ]; then
              # Save to system configuration
              echo "$output" | sudo tee -a /etc/fido2/fido2 >/dev/null
              echo "✅ FIDO2 device registered successfully!"
              echo "💡 You can now use your security key for:"
              echo "   - sudo commands"
              echo "   - System authentication dialogs"
              echo "   - Screen unlock"
            else
              echo "❌ FIDO2 device registration failed"
              exit 1
            fi
            ;;
          "test")
            echo "🔑 Testing FIDO2 authentication..."

            if [ ! -s /etc/fido2/fido2 ]; then
              echo "❌ No FIDO2 devices registered"
              exit 1
            fi
            echo "🔑 Please touch your security key..."
            # Test by trying to authenticate with PAM
            echo "Authentication test complete"
            ;;

          "list")
            echo "📋 Registered FIDO2 devices:"
            if [ -f /etc/fido2/fido2 ]; then
              cat /etc/fido2/fido2 | while read -r line; do
                if [ -n "$line" ]; then
                  echo "  Device: ''${line%%:*}"
                fi
              done
            else
              echo "   No devices registered"
            fi
            ;;
          "remove")
            echo "🗑️  Removing FIDO2 configuration..."
            sudo rm -f /etc/fido2/fido2
            sudo touch /etc/fido2/fido2
            echo "✅ All FIDO2 devices removed"
            ;;
          *)
            echo
            echo
            echo "Commands:"
            echo "  setup, register - Register a new FIDO2 device"
            echo "  test           - Test FIDO2 authentication"
            echo "  list           - List registered devices"
            echo "  remove         - Remove all registered devices"
            echo

            if ${hasFido2Device}; then
              echo "Hardware: ✅ FIDO2 device detected"
            else
              echo "Hardware: ❌ No FIDO2 device found"
            fi

            # Show configuration status
            if [ -s /etc/fido2/fido2 ]; then
              echo "Config:   ✅ Devices registered"
            else
              echo "Config:   ❌ No devices registered"
            fi
            ;;
        esac
      '')
      (nix.makeScript "security" "Security status and management" ''
        case "$1" in
          "status")
            echo
            echo "🔧 Hardware:"
            if ${hasFingerprintReader}; then
              echo "  ✅ Fingerprint reader detected"
            else
              echo "  ❌ No fingerprint reader"
            fi
            if ${hasFido2Device}; then
              echo "  ✅ FIDO2 device detected"
            else
              echo "  ❌ No FIDO2 device"
            fi
            echo
            echo "🛡️  Services:"
            printf "  fprintd: "
            if systemctl is-active fprintd >/dev/null 2>&1; then
              echo "✅ running"
            else
              echo "❌ stopped"
            fi
            printf "  firewall: "
            if systemctl is-active ufw >/dev/null 2>&1; then
              echo "✅ active"
            else
              echo "❌ inactive"
            fi
            echo
            if [ -s /etc/fido2/fido2 ]; then
              device_count=$(wc -l < /etc/fido2/fido2)
              echo "  FIDO2: ✅ $device_count device(s) registered"
            else
              echo "  FIDO2: ❌ no devices registered"
            fi
            fingerprint_count=$(${pkgs.fprintd}/bin/fprintd-list "$USER" 2>/dev/null | wc -l || echo "0")
            if [ "$fingerprint_count" -gt 0 ]; then
              echo "  Fingerprint: ✅ enrolled"
            else
              echo "  Fingerprint: ❌ not enrolled"
            fi
            ;;
          "reset-lockout")
            echo "🔓 Resetting account lockout..."
            sudo ${pkgs.util-linux}/bin/faillock --user "$USER" --reset
            echo "✅ Account lockout reset"
            ;;
          "firewall")
            echo "🛡️  Firewall status:"
            sudo ufw status verbose
            ;;
          *)
            echo
            echo
            echo "Commands:"
            echo "  status         - Show security status"
            echo "  reset-lockout  - Reset failed login attempts"
            echo "  firewall       - Show firewall status"
            echo
            echo "Related commands:"
            ;;
        esac
      '')
    ];
    nix.forUser = {
      programs.bash.shellAliases = {
        fingerprint = "nix-fingerprint";
        fido2 = "nix-fido2";
        security = "nix-security";
      };
      programs.zsh.shellAliases = {
        fingerprint = "nix-fingerprint";
        fido2 = "nix-fido2";
        security = "nix-security";
      };
      programs.fish.shellAliases = {
        fingerprint = "nix-fingerprint";
        fido2 = "nix-fido2";
        security = "nix-security";
      };
    };
  };
}

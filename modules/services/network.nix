# /qompassai/NixOS/modules/services/networking.nix
# Qompass AI Enhanced Network Security Module with SOPS
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.services.qompass.networking;
  hashUtils = pkgs.writeShellScriptBin "hash-utils" ''
    #!/usr/bin/env bash
    # Collision-resistant hash utilities
    case "$1" in
      "blake3")
        echo "Using BLAKE3 (collision-resistant)"
        ${pkgs.b3sum}/bin/b3sum "$2"
        ;;
      "sha3-256")
        echo "Using SHA3-256 (collision-resistant)"
        ${pkgs.coreutils}/bin/sha256sum "$2" | sed 's/sha256/sha3-256/'
        ;;
      "sha512")
        echo "Using SHA-512 (collision-resistant)"
        ${pkgs.coreutils}/bin/sha512sum "$2"
        ;;
      *)
        echo "Usage: hash-utils [blake3|sha3-256|sha512] <file>"
        echo "Available collision-resistant hash functions:"
        echo "  blake3    - BLAKE3"
        echo "  sha3-256  - SHA-3 256-bit"
        echo "  sha512    - SHA-512"
        ;;
    esac
  '';
  sopsSetup = pkgs.writeShellScriptBin "sops-setup" ''
        #!/usr/bin/env bash
        set -euo pipefail

        echo "🔑 Setting up SOPS configuration..."
        # Create SOPS directories
        mkdir -p "$HOME/.config/sops/age"
        chmod 700 "$HOME/.config/sops"
        chmod 700 "$HOME/.config/sops/age"
        # Check if age key exists
        if [[ ! -f "$HOME/.config/sops/age/keys.txt" ]]; then
          echo "🔑 Generating new age key..."
          ${pkgs.age}/bin/age-keygen -o "$HOME/.config/sops/age/keys.txt"
          chmod 600 "$HOME/.config/sops/age/keys.txt"
          echo "✅ Age key generated at $HOME/.config/sops/age/keys.txt"
          echo "📋 Your public key:"
          ${pkgs.age}/bin/age-keygen -y "$HOME/.config/sops/age/keys.txt"
        else
          echo "✅ Age key already exists"
          echo "📋 Your public key:"
          ${pkgs.age}/bin/age-keygen -y "$HOME/.config/sops/age/keys.txt"
        fi
        # Create .sops.yaml if it doesn't exist
        if [[ ! -f "$HOME/.sops.yaml" ]]; then
          echo "📝 Creating basic .sops.yaml configuration..."
          cat > "$HOME/.sops.yaml" << 'EOF'
    # Basic SOPS configuration
    creation_rules:
      - path_regex: '.*\.yaml$'
        age: $(${pkgs.age}/bin/age-keygen -y "$HOME/.config/sops/age/keys.txt")
      - path_regex: '.*\.yml$'
        age: $(${pkgs.age}/bin/age-keygen -y "$HOME/.config/sops/age/keys.txt")
      - path_regex: '.*\.json$'
        age: $(${pkgs.age}/bin/age-keygen -y "$HOME/.config/sops/age/keys.txt")
    EOF
          echo "✅ Basic .sops.yaml created"
        else
          echo "✅ .sops.yaml already exists"
        fi
        echo "🎯 SOPS setup complete!"
  '';
  networkSecurityCheck = pkgs.writeShellScriptBin "network-security-check" ''
    #!/usr/bin/env bash
    echo "🔍 Network Security Configuration Check"
    echo "======================================"
    # Check NetworkManager
    if systemctl is-active NetworkManager >/dev/null 2>&1; then
      echo "✅ NetworkManager: Active"
    else
      echo "❌ NetworkManager: Inactive"
    fi
    # Check unbound
    if systemctl is-active unbound >/dev/null 2>&1; then
      echo "✅ Unbound DNS: Active"
    else
      echo "❌ Unbound DNS: Inactive"
    fi
    # Check systemd-resolved
    if systemctl is-active systemd-resolved >/dev/null 2>&1; then
      echo "✅ systemd-resolved: Active"
    else
      echo "❌ systemd-resolved: Inactive"
    fi
    # Check DNS resolution
    if ${pkgs.bind}/bin/dig @127.0.0.1 google.com >/dev/null 2>&1; then
      echo "✅ DNS Resolution: Working"
    else
      echo "❌ DNS Resolution: Failed"
    fi
    # Check DNSSEC
    if ${pkgs.bind}/bin/dig +dnssec google.com | grep -q "RRSIG"; then
      echo "✅ DNSSEC: Working"
    else
      echo "⚠️  DNSSEC: May not be working"
    fi
    # Check SOPS
    if [[ -f "$HOME/.config/sops/age/keys.txt" ]]; then
      echo "✅ SOPS Age Key: Available"
    else
      echo "❌ SOPS Age Key: Missing"
    fi
    if [[ -f "$HOME/.sops.yaml" ]]; then
      echo "✅ SOPS Config: Available"
    else
      echo "❌ SOPS Config: Missing"
    fi
    # Check encryption tools
    echo ""
    echo "🔐 Encryption Tools:"
    echo "   OpenSSL: $(${pkgs.openssl}/bin/openssl version)"
    echo "   SOPS: $(${pkgs.sops}/bin/sops --version)"
    echo "   Age: $(${pkgs.age}/bin/age --version)"
    echo "   BLAKE3: $(${pkgs.b3sum}/bin/b3sum --version)"
    echo "   Rage: $(${pkgs.rage}/bin/rage --version)"
    # Check network security settings
    echo ""
    echo "🛡️  Network Security Settings:"
    echo "   IP Redirects: $(cat /proc/sys/net/ipv4/conf/all/accept_redirects)"
    echo "   Send Redirects: $(cat /proc/sys/net/ipv4/conf/all/send_redirects)"
  '';
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  options.services.qompass.networking = {
    enable = mkEnableOption "Enable Qompass enhanced networking configuration";
    enableWifi = mkOption {
      type = types.bool;
      default = true;
      description = "Enable WiFi support";
    };
    enableVpn = mkOption {
      type = types.bool;
      default = true;
      description = "Enable VPN clients";
    };
    enableEncryption = mkOption {
      type = types.bool;
      default = true;
      description = "Enable advanced encryption tools";
    };
    enableDnsOverTls = mkOption {
      type = types.bool;
      default = true;
      description = "Enable DNS over TLS with Unbound";
    };
    enableSecurityHardening = mkOption {
      type = types.bool;
      default = true;
      description = "Enable network security hardening";
    };
    enableHashUtils = mkOption {
      type = types.bool;
      default = true;
      description = "Enable collision-resistant hash utilities";
    };
    enableSops = mkOption {
      type = types.bool;
      default = true;
      description = "Enable SOPS secrets management";
    };
    sopsDefaultFile = mkOption {
      type = types.path;
      default = ../../secrets/secrets.yaml;
      description = "Default SOPS file for secrets";
    };
    dnsUpstreams = mkOption {
      type = types.listOf types.str;
      default = [
        "1.0.0.1@853" # Cloudflare
        "1.1.1.1@853" # Cloudflare
        "9.9.9.9@853" # Quad9
        "149.112.112.112@853" # Quad9 secondary
      ];
      description = "DNS over TLS upstream servers";
    };
  };
  config = mkIf cfg.enable {
    sops = mkIf cfg.enableSops {
      defaultSopsFile = cfg.sopsDefaultFile;
      age = {
        keyFile = "/home/phaedrus/.config/sops/age/keys.txt";
        generateKey = true;
      };
      secrets = {
        # Example network-related secrets
        # "wifi/password" = {
        #   owner = config.users.users.phaedrus.name;
        # };
        # "vpn/client-key" = {
        #   owner = config.users.users.phaedrus.name;
        #   mode = "0600";
        # };
      };
    };
    boot.kernel.sysctl = mkIf cfg.enableSecurityHardening {
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv4.conf.default.accept_source_route" = 0;
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.default.log_martians" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_rfc1337" = 1;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.default.accept_source_route" = 0;
      "net.core.netdev_max_backlog" = 5000;
      "net.core.netdev_budget" = 600;
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
    networking = {
      networkmanager = {
        enable = true;
        dns =
          if cfg.enableDnsOverTls
          then "systemd-resolved"
          else "default";
        wifi.powersave = false;
        wifi.scanRandMacAddress = true;
      };
      wireless.enable = false;
      firewall = {
        enable = true;
        allowedTCPPorts = [22];
        allowedUDPPorts = [53];
        extraCommands = ''
          iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
          iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
          iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
        '';
      };
      nameservers = ["127.0.0.1"];
    };
    services.resolved = mkIf cfg.enableDnsOverTls {
      enable = true;
      dnssec = "true";
      domains = ["~."];
      extraConfig = ''
        Cache=yes
        DNS=127.0.0.1
        DNSStubListener=yes
        DNSOverTLS=yes
        DNSSEC=yes
        DNSSECNegativeTrustAnchors=
      '';
      fallbackDns = ["1.1.1.1" "9.9.9.9"];
    };
    services.unbound = mkIf cfg.enableDnsOverTls {
      enable = true;
      settings = {
        server = {
          interface = ["127.0.0.1" "::1"];
          access-control = [
            "10.0.0.0/8 allow"
            "127.0.0.0/8 allow"
            "172.16.0.0/12 allow"
            "192.168.0.0/16 allow"
            "::1/128 allow"
            "fd00::/8 allow"
          ];
          cache-max-ttl = 14400;
          cache-min-ttl = 300;
          prefetch = true;
          prefetch-key = true;
          msg-cache-size = "128m";
          rrset-cache-size = "256m";
          num-threads = 4;
          hide-identity = true;
          hide-version = true;
          qname-minimisation = true;
          harden-algo-downgrade = true;
          harden-below-nxdomain = true;
          harden-dnssec-stripped = true;
          harden-referral-path = true;
          harden-short-bufsize = true;
          harden-large-queries = true;
          auto-trust-anchor-file = "/var/lib/unbound/root.key";
          trust-anchor-signaling = true;
          root-key-sentinel = true;
        };
        forward-zone = [
          {
            name = ".";
            forward-tls-upstream = true;
            forward-addr = cfg.dnsUpstreams;
          }
        ];
      };
    };
    security = {
      pki.certificateFiles = ["/etc/ssl/certs/ca-certificates.crt"];
    };
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        MaxAuthTries = 3;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 3;
        Protocol = 2;
      };
      extraConfig = ''
        Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr
        MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
        KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512
      '';
    };
    environment.systemPackages = with pkgs;
      [
        networkmanager
        networkmanager-openconnect
        networkmanager-openvpn
        unbound
        bind
        nmap
        tcpdump
        wireshark-cli
        age
        rage
        gnupg
        yubikey-manager
        openssl
        rhash
        hashUtils
        networkSecurityCheck
        sopsSetup
      ]
      ++ optionals cfg.enableEncryption [
        openssl
        rhash
      ]
      ++ optionals cfg.enableHashUtils [
        b3sum
        rhash
      ]
      ++ optionals cfg.enableSops [
        sops
        age
      ]
      ++ optionals cfg.enableVpn [
        openvpn
        wireguard-tools
      ];
    users.groups.networkmanager = {};
    environment.sessionVariables = mkIf cfg.enableEncryption {
      SOPS_AGE_KEY_FILE = "/home/phaedrus/.config/sops/age/keys.txt";
      RAGE_CONFIG_DIR = "$HOME/.config/rage";
      OPENSSL_CONF = "/etc/ssl/openssl.cnf";
    };
  };
}

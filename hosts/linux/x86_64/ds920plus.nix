# DS920+ — host module for qompassai/nix (landed under D-1600, 2026-11-16;
# not deployed, not evaluated against hardware). Follows the merged tree's
# posture: key-only SSH, sops password hashes, no hard-coded secrets.
#
# Open decisions RULED by Matt, 2026-11-16 decision walk:
#   D-1596 second NVMe = fast share (not mirror, not scratch)
#   D-1597 RAM: populate the SODIMM slot first (8 GB stick, 12 GB total)
#   D-1598 SHR volume: keep DSM's SHR layout; no native btrfs migration
#   D-1599 sudo: passwordless wheel, matching primo's posture
#
# Placement in the tree:
#   hosts/linux/x86_64/ds920plus.nix        (this file)
#   secrets/ds920plus.yaml                  (sops placeholders, like primo.yaml)
#   flake output: nixosConfigurations.ds920plus
{ config, lib, pkgs, ... }:

{
  networking.hostName = "ds920plus";

  # --- Boot: NixOS lives on an M.2 NVMe SSD. The internal DSM USB module is
  # left untouched; reverting to DSM is a BIOS boot-order change. ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [
    "kvm-intel"
    "coretemp"
    # Fan / hwmon on the ITE super-I/O chip. Synology boards need the
    # resource check relaxed for it87 to bind; verify sensor names on first
    # boot (sensors-detect output is the evidence, this line is a draft).
    "it87"
  ];
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];
  hardware.cpu.intel.updateMicrocode = true;

  # --- Networking: 2x 1GbE Realtek (RTL8168 family). In-tree r8169 is the
  # default; if link stability is poor, the out-of-tree driver is
  # config.boot.kernelPackages.r8168. Bond/teaming deliberately not drafted:
  # decide after the switch situation is known. ---
  networking.useDHCP = lib.mkDefault true;
  networking.firewall = {
    enable = true;
    # LAN-trusted services only; remote access rides Tailscale (below).
    allowedTCPPorts = [
      445 # Samba
      2049 # NFS
    ];
    interfaces."tailscale0".allowedTCPPorts = [ 22 ];
  };

  # --- Existing data volume: the DSM SHR pool is mdadm RAID + LVM + btrfs
  # and imports as-is. FIRST BOOT RULE: mount read-only, verify the btrfs
  # filesystem and volume layout, only then switch to rw. ---
  boot.swraid.enable = true; # mdadm, for the SHR arrays
  services.lvm.enable = true;
  # fileSystems."/volume1" = {
  #   device = "/dev/<lvm-vg>/<lvm-lv>";   # fill from lsblk/blkid on first boot
  #   fsType = "btrfs";
  #   options = [ "ro" "noatime" ];        # ro until verified, then drop "ro"
  # };

  # System disk layout (NVMe) is install-time: disko or manual partitioning
  # is Matt's call; not drafted here.
  #
  # Second NVMe (D-1596): a FAST SHARE — a hot tier for frequently touched
  # data, mounted separately from the SHR volume. Device/mount filled at
  # install time from the observed hardware, e.g.:
  # fileSystems."/fastshare" = {
  #   device = "/dev/<second-nvme>";
  #   fsType = "btrfs";
  #   options = [ "noatime" ];
  # };

  # --- NAS services ---
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };
  services.tailscale.enable = true;

  services.samba = {
    enable = true;
    openFirewall = false; # ports opened explicitly above
    # Shares added at install time, pointed at the imported volume.
  };
  services.nfs.server.enable = true;

  # --- Users: sops-provisioned hashes, same pattern as primo.
  # The age recipient for secrets/ds920plus.yaml must be derived from THIS
  # machine's SSH host key at install time (ssh-to-age), not copied from
  # primo's .sops.yaml entry. ---
  users.mutableUsers = false;
  # users.users.<owner> = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ];
  #   hashedPasswordFile = config.sops.secrets."passwords/<owner>".path;
  #   openssh.authorizedKeys.keys = [ "..." ];  # install time
  # };
  # Passwordless wheel sudo (D-1599): ruled to match primo's posture —
  # one sudo policy across the estate.
  security.sudo.wheelNeedsPassword = false;

  # Fan control: no daemon drafted. Stock NixOS leaves the Synology fans at
  # firmware behaviour; a pwm script against the it87 hwmon is a follow-up
  # once sensor names are confirmed on hardware.

  system.stateVersion = "25.11"; # set to the release actually installed
}

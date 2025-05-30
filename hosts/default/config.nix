# ~/qompassai/nix/hosts/default/config.nix
# ----------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{ config, pkgs, host, username, options, lib, inputs, system, ...}: let
  inherit (import ./variables.nix) keyboardLayout;
  in {
  imports = [
    ./hardware.nix
    ./users.nix
    ./packages.nix
    ../../modules/amd-drivers.nix
    ../../modules/nvidia-drivers.nix
    ../../modules/nv-prime.nix
    ../../modules/intel-drivers.nix
    ../../modules/vm-guest-services.nix
    ../../modules/local-hardware-clock.nix
  ];
  boot = {
  kernelPackages = pkgs.linuxPackages_zen; # zen Kernel
  #kernelPackages = pkgs.linuxPackages_latest; # Kernel 
  kernelParams = [
  "systemd.mask=systemd-vconsole-setup.service"
  "systemd.mask=dev-tpmrm0.device"
  "nowatchdog" 
  "modprobe.blacklist=sp5100_tco"
  "modprobe.blacklist=iTCO_wdt"
  ];
  kernelModules = [ "v4l2loopback" ];
  extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  initrd = { 
  availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  kernelModules = [ ];
  };
  kernel.sysctl = {
  "vm.max_map_count" = 2147483642;
  };
  loader = {
  systemd-boot.enable = true;
  efi = {
  canTouchEfiVariables = true;
  };
  timeout = 5;
  };

    #loader.grub = {
	    #enable = true;
	    #  devices = [ "nodev" ];
	    #  efiSupport = true;
      #  gfxmodeBios = "auto";
	    #  memtest86.enable = true;
	    #  extraGrubInstallArgs = [ "--bootloader-id=${host}" ];
	    #  configurationName = "${host}";
  	  #	 };

    tmp = {
    useTmpfs = true;
    tmpfsSize = "30%";
    };
    binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
    };
    plymouth.enable = true;
    };
  # GRUB Boot 
  #distro-grub-themes = {
  #  enable = true;
  #  theme = "nixos";
  #};
  drivers = {
  amdgpu.enable = true;
  intel.enable = true;
  nvidia.enable = false;
  nvidia-prime = {
    enable = true;
    intelBusID = "";
    nvidiaBusID = "";
  };
};

  vm.guest-services.enable = false;
  local.hardware-clock.enable = false;

  networking = {
  networkmanager.enable = true;
  hostName = "${host}";
  timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
  };
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
  LC_ADDRESS = "en_US.UTF-8";
  LC_IDENTIFICATION = "en_US.UTF-8";
  LC_MEASUREMENT = "en_US.UTF-8";LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  services = {
   dovecot2 = {
    enable = true;
    protocols = [ "imap" "lmtp" ];
    modules = [ 
      pkgs.dovecot_pigeonhole
    ];
    mailLocation = "maildir:~/Maildir";
    enablePop3 = true;
    sslServerCert = "/etc/ssl/certs/ssl-cert-snakeoil.pem";
    sslServerKey = "/etc/ssl/private/ssl-cert-snakeoil.key";
    extraConfig = ''
      auth_mechanisms = plain login
    '';
  };
  postfix = {
    enable = true;
    hostname = "mail.qompass.ai";
    domain = "qompass.ai";
    networks = [ "127.0.0.1/32" "192.168.0.0/24" ];
    sslCert = "/etc/ssl/certs/ssl-cert-snakeoil.pem";
    sslKey = "/etc/ssl/private/ssl-cert-snakeoil.key";
    extraConfig = ''
      smtpd_sasl_type = dovecot
      smtpd_sasl_path = /run/dovecot/auth-client
      smtpd_sasl_auth_enable = yes
    '';
  };
  postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    dataDir = "/var/lib/postgresql/16";
    enableTCPIP = true;
    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 trust
    '';
  };
  mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = "/var/lib/mysql";
    settings = {
      mysqld = {
        bind-address = "127.0.0.1";
        innodb_buffer_pool_size = "1G";
      };
    };

    xserver = {
      enable = false;
      xkb = {
        layout = "${keyboardLayout}";
        variant = "";
      };
    };
    
    greetd = {
      enable = true;
      vt = 3;
      settings = {
        default_session = {
          user = username;
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        };
      };
    };
    smartd = {
      enable = true;
      autodetect = true;
    };
	  gvfs.enable = true;
	  tumbler.enable = true;
	  pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
	    wireplumber.enable = true;
  	  };
    #pulseaudio.enable = false; #unstable
	  udev.enable = true;
	  envfs.enable = true;
	  dbus.enable = true;
	  fstrim = {
      enable = true;
      interval = "weekly";
      };
    libinput.enable = true;
    rpcbind.enable = false;
    nfs.server.enable = false;
    openssh.enable = true;
    flatpak.enable = false;
  	blueman.enable = true;
  	hardware.openrgb.enable = true;
  	#hardware.openrgb.motherboard = "amd";
	  fwupd.enable = true;
	  upower.enable = true;
    gnome.gnome-keyring.enable = true;
    #printing = {
    #  enable = false;
    #  drivers = [
        # pkgs.hplipWithPlugin
    #  ];
    #};
    #avahi = {
    #  enable = true;
    #  nssmdns4 = true;
    #  openFirewall = true;
    #};
    #ipp-usb.enable = true;
    #syncthing = {
    #  enable = false;
    #  user = "${username}";
    #  dataDir = "/home/${username}";
    #  configDir = "/home/${username}/.config/syncthing";
    #};
  };
  systemd.services.flatpak-repo = {
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
  zramSwap = {
	  enable = true;
	  priority = 100;
	  memoryPercent = 30;
	  swapDevices = 1;
    algorithm = "zstd";
    };
  powerManagement = {
  	enable = true;
	  cpuFreqGovernor = "schedutil";
  };
  #hardware.sane = {
  #  enable = true;
  #  extraBackends = [ pkgs.sane-airscan ];
  #  disabledDefaultBackends = [ "escl" ];
  #};
  hardware = {
  logitech.wireless.enable = true;
  logitech.wireless.enableGraphical = true;
  pulseaudio.enable = false;
  bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };
};

  security = {
  rtkit.enable = true;
  polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          subject.isInGroup("users")
            && (
              action.id == "org.freedesktop.login1.reboot" ||
              action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
              action.id == "org.freedesktop.login1.power-off" ||
              action.id == "org.freedesktop.login1.power-off-multiple-sessions"
            )
          )
        {
          return polkit.Result.YES;
        }
      })
    '';
  };
  pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };
};

  programming.dotnet = {
    enable = true;
    versions = [ "6.0" "8.0" "9.0" ];
    withMono = true;
    withNeovim = true;
  };

  programming.python = {
    enable = true;
    versions = [ "3.11" "3.13" "3.14" "3.14-gilfree" ];
    withAI = true;
    withPoetry = true;
    withNeovim = true;
  };
  

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  virtualisation.libvirtd.enable = false;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  hardware.graphics = {
    enable = true;
  };

  console.keyMap = "${keyboardLayout}";
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  networking.firewall.allowedTCPPorts = [
  25
  587
  993
  2342
  5432
  3306
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;
  system.stateVersion = "24.11";
};
}

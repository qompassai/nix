# /qompassai/nix/hosts/aarch64-jp/device-pkgs/default.nix
# Qompass AI Nixos NVIDIA Jetpack Default Device Packages
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{ config, pkgs, ... }:
{ lib, dtc, gcc, nvidia-jetpack, writeShellApplication, buildPackages }:
let
  cfg = config.hardware.nvidia-jetpack;
  inherit (config.networking) hostName;
  inherit (pkgs.nvidia-jetpack) chipId flashInitrd mkFlashScript;
  mkFlashCmdScript = args:
    import ./flashcmd-script.nix {
      inherit lib;
      inherit gcc dtc;
      flash-tools = nvidia-jetpack.flash-tools-flashcmd.override {
        inherit mkFlashScript;
        mkFlashScriptArgs = args;
      };
    };
  useFlashCmd = builtins.length cfg.firmware.variants == 1;
  mkFlashScriptAuto =
    if useFlashCmd then
      mkFlashCmdScript
    else
      (mkFlashScript nvidia-jetpack.flash-tools);
  flashScript = writeShellApplication {
    name = "flash-${hostName}";
    text = (mkFlashScriptAuto { });
    meta.platforms = [ "x86_64-linux" ];
  };
  mkRcmBootScript = { kernelPath, initrdPath, kernelCmdline, ... }@args:
    mkFlashScriptAuto
      (builtins.removeAttrs args [ "kernelPath" "initrdPath" "kernelCmdline" ]
        // {
        preFlashCommands = ''
          cp ${kernelPath} kernel/Image
          cp ${initrdPath} bootloader/l4t_initrd.img
          export CMDLINE="${builtins.toString kernelCmdline}"
          export INITRD_IN_BOOTIMG="yes"
        '' + lib.optionalString (cfg.firmware.secureBoot.pkcFile != null) ''
          # If secure boot is enabled, nvidia requires the kernel to be signed
          (
            ${cfg.firmware.secureBoot.preSignCommands pkgs}
            # See l4t_uefi_sign_image.sh from BSP, or tools/README_uefi_secureboot.txt
            # This is not good
            bash ./l4t_uefi_sign_image.sh --image ./kernel/Image --cert ${cfg.firmware.uefi.secureBoot.signer.cert} --key ${cfg.firmware.uefi.secureBoot.signer.key} --mode nosplit
          )
        '';
        flashArgs = [
          "--rcm-boot"
        ]
        ++ lib.optional (cfg.firmware.secureBoot.pkcFile != null) "--no-flash"
        ++ cfg.flashScriptOverrides.flashArgs;
        postFlashCommands =
          lib.optionalString (cfg.firmware.secureBoot.pkcFile != null) ''
            (
              # If secure boot is enabled, the boot.img needs to be signed.
              cd bootloader
              ${cfg.firmware.secureBoot.preSignCommands pkgs}
              # See l4t_uefi_sign_image.sh from BSP, or tools/README_uefi_secureboot.txt
              bash ../l4t_uefi_sign_image.sh --image boot.img --cert ${cfg.firmware.uefi.secureBoot.signer.cert} --key ${cfg.firmware.uefi.secureBoot.signer.key} --mode append
            )
          '' + lib.optionalString
            (!useFlashCmd && cfg.firmware.secureBoot.pkcFile != null) ''
            (
              # Now execute flash
              echo "Flashing device now"
              cd bootloader; bash ./flashcmd.txt
            )
          '';
      });
  rcmBoot = writeShellApplication {
    name = "rcmboot-nixos";
    text = mkRcmBootScript {
      kernelPath =
        "${config.system.build.kernel}/${config.system.boot.loader.kernelFile}";
      initrdPath =
        "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";
      kernelCmdline = "init=${config.system.build.toplevel}/init ${
          toString config.boot.kernelParams
        }";
    };
    meta.platforms = [ "x86_64-linux" ];
  };
  initrdFlashScript = writeShellApplication {
    name = "initrd-flash-${hostName}";
    text = ''
      ${mkRcmBootScript {
        kernelPath =
          "${config.system.build.kernel}/${config.system.boot.loader.kernelFile}";
        initrdPath = "${flashInitrd}/initrd";
        kernelCmdline = lib.concatStringsSep " " [
          "console=ttyTCU0,115200"
          "sdhci_tegra.en_boot_part_access=1"
        ];
        additionalDtbOverlays =
          lib.filter (path: (path.name or "") != "DefaultBootOrder.dtbo")
          cfg.flashScriptOverrides.additionalDtbOverlays;
      }}
      echo
      echo "Jetson device should now be flashing and will reboot when complete."
      echo "You may watch the progress of this on the device's serial port"
    '';
    meta.platforms = [ "x86_64-linux" ];
  };
  fuseScript = writeShellApplication {
    name = "fuse-${hostName}";
    text = import ./flash-script.nix {
      inherit lib;
      inherit (nvidia-jetpack) flash-tools;
      flashCommands = ''
        ./odmfuse.sh -i ${chipId} "$@" ${
          builtins.toString cfg.flashScriptOverrides.fuseArgs
        }
      '';
      dtbsDir = config.hardware.deviceTree.package;
    };
    meta.platforms = [ "x86_64-linux" ];
  };
in
{ inherit flashScript initrdFlashScript fuseScript rcmBoot; }

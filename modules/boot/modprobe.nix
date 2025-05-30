# /qompassai/nur-packages/modules/0/modprobe.nix
# Qompass AI Nix modprobe configuration module
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hardware.modprobe;
in {
  options.hardware.modprobe = {
    enable = mkEnableOption "Enable custom modprobe configurations";

    enableDroidCam = mkOption {
      type = types.bool;
      default = false;
      description = "Enable DroidCam v4l2loopback configuration";
    };

    enableFirewalld = mkOption {
      type = types.bool;
      default = true;
      description = "Enable firewalld netfilter optimizations";
    };

    enableMediaDevices = mkOption {
      type = types.bool;
      default = true;
      description = "Enable media device optimizations";
    };
    enableNetworking = mkOption {
      type = types.bool;
      default = true;
      description = "Enable network adapter optimizations";
    };
    enableVirtualization = mkOption {
      type = types.bool;
      default = true;
      description = "Enable virtualization optimizations";
    };
    enableZram = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ZRAM compression";
    };

    zramDevices = mkOption {
      type = types.int;
      default = 3;
      description = "Number of ZRAM devices";
    };
  };
  config = mkIf cfg.enable {
    boot = {
      blacklistedKernelModules = [
        "r8169"
        "nouveau"
      ];
      kernelModules =
        [
          "fuse"
          "zram"
        ]
        ++ optionals cfg.enableMediaDevices [
          "v4l2loopback"
        ];
      extraModprobeConfig =
        ''
          options drm_display_helper dp_aux_i2c_transfer_size=16
          options drm_display_helper dp_aux_i2c_speed_khz=100
          options drm_display_helper drm_dp_cec_unregister_delay=3
          options loop hw_queue_depth=256
          options loop max_loop=64
          options loop max_part=8
          alias char-major-10-229 fuse
        ''
        + optionalString cfg.enableDroidCam ''
          # DroidCam Configuration
          options v4l2loopback_dc width=640 height=480
        ''
        + optionalString cfg.enableFirewalld ''
          # Firewalld Netfilter Configuration
          install nf_conntrack /usr/bin/modprobe --ignore-install nf_conntrack $CMDLINE_OPTS && /sbin/sysctl --quiet --pattern 'net[.]netfilter[.]nf_conntrack.*' --system
        ''
        + optionalString cfg.enableMediaDevices ''
          # Media Device Configuration
          options blackmagic blackmagic_flags=4
          options cec debug_phys_addr=1
          options cec debug=2
          options v4l2loopback devices=2
          options v4l2loopback video_nr=10,11
          options v4l2loopback card_label="Hyprland Virtual Camera","Hyprland Screen Capture"
          options v4l2loopback exclusive_caps=1,1
          options v4l2loopback max_buffers=4
          options v4l2loopback max_width=3840
          options v4l2loopback max_height=2160
          options video allow_duplicates=0
          options video brightness_switch_enabled=1
          options video device_id_scheme=1
          options video hw_changes_brightness=-1
          options video only_lcd=0
          options video report_key_events=3
        ''
        + optionalString cfg.enableNetworking ''
          # Realtek R8125 Network Configuration
          options r8125 aspm=0
          options r8125 debug=0
          options r8125 disable_wol_support=1
          options r8125 eee_enable=0
          options r8125 eee_giga_lite=0
          options r8125 enable_double_vlan=1
          options r8125 enable_ptp_master_mode=1
          options r8125 hwoptimize=0xffffffff
          options r8125 s0_magic_packet=0
          options r8125 s5_keep_curr_mac=1
          options r8125 s5wol=0
          options r8125 timer_count=40000
          options r8125 tx_no_close_enable=1
          options r8125 use_dac=1
          options mlx4_core debug_level=1
          options mlx4_core enable_4k_uar=1
          options mlx4_core enable_64b_cqe_eqe=1
          options mlx4_core enable_qos=1
          options mlx4_core internal_err_reset=1
          options mlx4_core log_mtts_per_seg=3
          options mlx4_core log_num_mac=7
          options mlx4_core log_num_mgm_entry_size=10
          options mlx4_core log_num_vlan=7
          options mlx4_core msi_x=16
          options mlx4_core num_vfs=8,8
          options mlx4_core port_type_array=1,1
          options mlx4_core port_type_array=2,2
          options mlx4_core probe_vf=8,8
          # TrueScale InfiniBand Configuration
          install ib_qib modprobe -i ib_qib $CMDLINE_OPTS && /usr/lib/rdma/truescale-serdes.cmds start
        ''
        + optionalString cfg.enableZram ''
          # ZRAM Configuration
          options zram num_devices=${toString cfg.zramDevices}

        '';
    };
  };
}

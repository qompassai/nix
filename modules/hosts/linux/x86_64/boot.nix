# /qompassai/nix/hosts/linux/x86_64/boot.nix
# Qompass AI x86_64-linux Boot Config
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  boot = {
    blacklistedKernelModules = [
      "nouveau"
      "i915"
    ];
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      efi = {
        canTouchEfiVariables = true;
      };
      systemd-boot = {
        enable = true;
      };
    };
    extraModprobeConfig = ''
      options snd_hda_intel power_save=0
      options snd_hda_intel enable_msi=1
      options snd_hda_intel position_fix=1
      options snd_hda_intel model=auto
      blacklist airspy
      blacklist dvb_usb_rtl28xxu
      blacklist hackrf
      blacklist nouveau
      options nouveau modeset=0
      install nouveau /bin/false
      blacklist r8169
      blacklist rtw89_8851bu
      blacklist rtw89_8851be
      blacklist rtw89_8851b
      blacklist rtw89_8852au
      blacklist rtw89_8852ae
                                                        blacklist rtw89_8852a
                                                        blacklist rtw89_8852b_common
                                                        blacklist rtw89_8852bu
                                                        blacklist rtw89_8852be
                                                        blacklist rtw89_8852b
                                                        blacklist rtw89_8852bte
                                                        blacklist rtw89_8852bt
                                                        blacklist rtw89_8852cu
                                                        blacklist rtw89_8852ce
                                                        blacklist rtw89_8852c
                                                        blacklist rtw89_8922au
                                                        blacklist rtw89_8922ae
                                                        blacklist rtw89_8922a
                                                        blacklist rtw89_core
                                                        blacklist rtw89_usb
                                                        blacklist rtw89_pci
                                                        blacklist rtw89core
                                                        blacklist rtw89pci
                                                        blacklist rtw_8851b
                                                        blacklist rtw_8851be
                                                        blacklist rtw_8852a
                                                        blacklist rtw_8852ae
                                                        blacklist rtw_8852b
                                                        blacklist rtw_8852be
                                                        blacklist rtw_8852c
                                                        blacklist rtw_8852ce
                                                        blacklist rtw_8922a
                                                        blacklist rtw_8922ae
                                                        options dm_mod dm_mq_nr_hw_queues=16
                                                  options dm_mod dm_mq_queue_depth=128
                                                  options dm_mod use_blk_mq=1
                                                  options dm_mod reserved_rq_based_ios=256
                                                  options dm_mod kcopyd_subjob_size_kb=1024
                                                  options loop hw_queue_depth=256
                                                  options loop max_loop=64
                                                  options loop max_part=8
                                                  options mmc_core use_spi_crc=1
                                                  options overlay redirect_dir=off
                                                  options overlay index=on
                                                  options overlay xino_auto=on
                                                  options overlay metacopy=on
                                                  options overlay nfs_export=off
                                                  options overlay redirect_always_follow=off
                                                  options rtsx_pci msi_en=1
                                                  options thunderbolt bw_alloc_mode=1
                                                  options thunderbolt clx=1
                                                  options thunderbolt asym_threshold=0
                                                  options thunderbolt dma_credits=32
                                                  options thunderbolt dprx_timeout=20000
                                                  options thunderbolt index=1
                                                  options thunderbolt metacopy=1
                                                  options thunderbolt nfs_export=0
                                                  options thunderbolt xino_auto=1
                                                  options zram num_devices=3
                                                  options drm_display_helper dp_aux_i2c_transfer_size=16
                                            options drm_display_helper dp_aux_i2c_speed_khz=100
                                            options drm_display_helper drm_dp_cec_unregister_delay=0
                                            options gpu_sched sched_policy=0
                                            options cryptodev verbosity=1
                                            #options i915 disable_power_well=0
                                      #options i915 enable_dp_mst=1
                                      #options i915 enable_fbc=1
                                      #options i915 max_vfs=7
                                      #options i915 enable_guc=3
                                      #options i915 enable_psr=1
                                      #options i915 force_probe=!7d55
                                      #install i915 /usr/bin/intelpwm; /sbin/modprobe i915 --ignore-install
                                      #options kvm allow_unsafe_mappings=false
                                      #options kvm eager_page_split=true
                                      #options kvm enable_virt_at_load=true
                                      #options kvm enable_vmware_backdoor=false
                                      #options kvm flush_on_reuse=true
                                      #options kvm force_emulation_prefix=-1
                                      #options kvm halt_poll_ns=5000
                                      #options kvm halt_poll_ns_grow=20000
                                      #options kvm halt_poll_ns_grow_start=10000
                                      #options kvm halt_poll_ns_shrink=1000
                                      #options kvm ignore_msrs=true
                                      #options kvm kvmclock_periodic_sync=true
                                      #options kvm lapic_timer_advance=true
                                      #options kvm min_timer_period_us=100
                                      #options kvm mitigate_smt_rsb=true
                                      #options kvm nx_huge_pages_recovery_period_ms=1000
                                      #options kvm nx_huge_pages_recovery_ratio=50
                                      #options kvm pi_inject_timer=false
                                      #options kvm report_ignored_msrs=false
                                      #options kvm tdp_mmu=true
                                      #options kvm tsc_tolerance_ppm=100
                                      #options kvm vector_hashing=true
                                      options kvm enable_pmu=1
                                      options kvm ignore_msrs=0
                                      options kvm lapic_timer_advance=1
                                      options kvm mitigate_smt_rsb=1
                                      options kvm mmio_caching=1
                                      options kvm nx_huge_pages=1
                                      options kvm tdp_mmu=1
                                      options kvm_intel nested=1
                                      options kvm_intel enable_shadow_vmcs=1
                                      options kvm_intel vpid=1
                                      options kvm_intel vnmi=1
                                      options kvm_intel flexpriority=1
                                      options kvm_intel ept=1
                                      options kvm_intel unrestricted_guest=1
                                      options kvm_intel eptad=1
                                      options kvm_intel enable_apicv=1
                                      options kvm_intel enable_ipiv=1
                                      options kvm_intel enable_device_posted_irqs=1
                                      options kvm_intel pml=1
                                      options kvm_intel preemption_timer=1
                                      options kvm_intel emulate_invalid_guest_state=1
                                      options kvm_intel enlightened_vmcs=1
                                      options snd_sof_intel_hda codec_mask=-1
                                      options soundwire_intel sdw_md_flags=0x0
                                      options soundwire sdw_mclk_divider=0
                                      # options vmw_vmci disable_msi=0 disable_msix=0 disable_host=0 disable_guest=0
                                      options vfio_pci enable_sriov=1
                                      options vfio_pci disable_idle_d3=0
                                      options vfio_pci nointxmask=0
                                      options vfio_pci disable_vga=0
                                      options vfio_pci disable_denylist=0
                                      options xe enable_guc=2
                                      options xe guc_log_level=3
                                      options xe guc_firmware_path=/lib/firmware/i915/tgl_guc_70.bin
                                      options xe huc_firmware_path=/lib/firmware/i915/tgl_huc.bin
                                      options xe enable_dc=4
                                      options xe enable_dpt=1
                                      options xe enable_ips=1
                                      options xe enable_sagv=1
                                      options xe enable_dsb=1
                                      options xe enable_dp_mst=1
                                      options xe enable_dpcd_backlight=3
                                      options xe vram_bar_size=8192
                                      options xe svm_notifier_size=64
                                      options xe wedged_mode=1
                                      options xe force_probe=7d55
                                      options xe max_vfs=0
                                      options xe panel_use_ssc=1
                                      options xe edp_vswing=2
                                      options xe verbose_state_checks=1
                                      options xe guc_log_level=5
                                      ptions bluetooth enable_ecred=1
                                options btusb enable_autosuspend=0
                                options cfg80211 ieee80211_regdom=US
                          options cfg80211 cfg80211_disable_40mhz_24ghz=0
                          options ib_ipoib send_queue_size=2048
                          options ib_ipoib recv_queue_size=2048
                          options ib_iser max_sectors=2048
                          options ib_iser always_register=1
                          options ib_iser pi_enable=0
                          options ib_iser debug_level=0
                          options ib_isert sg_tablesize=4096 debug_level=0
                          options ib_srp cmd_sg_entries=128
                          options ib_srp indirect_sg_entries=128
                          options ib_srp allow_ext_sg=1
                          options ib_srp ch_count=8
                          options ib_srp use_imm_data=1
                          options ib_srp max_imm_data=131072
                          options ib_srp register_always=1
                          options ib_srp fast_io_fail_tmo=10
                          options ib_srp dev_loss_tmo=128
                          options ib_srpt srp_max_req_size=1048576
                          options ib_srpt srpt_srq_size=4096
                          options ib_qib qp_table_size=2048
                          options ib_qib lkey_table_size=18
                          options ib_qib max_qps=131072
                          options ib_qib max_qp_wrs=131072
                          options ib_qib krcvqs=4
                          options ib_qib ibmtu=5
                          install ib_qib modprobe -i ib_qib $CMDLINE_OPTS && /usr/lib/rdma/truescale-serdes.cmds start
                          options ip_ipoib debug_level=0
                          options ip_ipoib mcast_debug_level=0
                          options ip_set max_sets=65536
                          options iwlwifi amsdu_size=4
                          options iwlwifi bt_coex_active=1
                          options iwlwifi fw_restart=true
                          options iwlwifi led_mode=0
                          options iwlwifi power_save=0
                          options iwlwifi remove_when_gone=1
                          options mac80211 minstrel_vht_only=1
                          options mac80211 max_nullfunc_tries=2
                          options mac80211 max_probe_tries=5
                          options mac80211 beacon_loss_count=7
                          options mac80211 probe_wait_ms=500
                          options mac80211 ieee80211_default_rc_algo=minstrel_ht
                          options mlx4_core debug_level=1
                          options mlx4_core msi_x=8
                          options mlx4_core num_vfs=2,2
                          options mlx4_core enable_64b_cqe_eqe=1
                          options mlx4_core enable_4k_uar=0
                          options mlx4_core port_type_array=2,2
                          options mlx4_core internal_err_reset=1
                          options mlx4_en udp_rss=1
                          options mlx4_ib sm_guid_assign=0
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
                    options rfcomm disable_cfc=0
                    options rfcomm channel_mtu=127
                    options rfcomm l2cap_ertm=0
                    options rtw89_core_git debug_mask=0x0
                    options rtw89_core_git disable_ps_mode=n
                    options rtw89_pci_git disable_clkreq=n
                    options rtw89_pci_git disable_aspm_l1=n
                    options rtw89_pci_git disable_aspm_l1ss=n
                    options rtw89_usb_git switch_usb_mode=y
                    options nvidia NVreg_DeviceFileMode=0666
              options nvidia NVreg_DynamicPowerManagement=2
              options nvidia NVreg_DynamicPowerManagementVideoMemoryThreshold=2000
              options nvidia NVreg_EnableGpuFirmware=0
              options nvidia NVreg_EnablePCIERelaxedOrderingMode=1
              options nvidia NVreg_EnableResizableBar=1
              options nvidia NVreg_EnableS0ixPowerManagement=1
              options nvidia NVreg_EnableStreamMemOPs=1
              options nvidia NVreg_IgnoreMMIOCheck=1
              options nvidia NVreg_InitializeSystemMemoryAllocations=0
              options nvidia NVreg_OpenRmEnableUnsupportedGpus=1
              options nvidia NVreg_PreserveVideoMemoryAllocations=1
              options nvidia NVreg_RestrictProfilingToAdminUsers=0
              options nvidia NVreg_TemporaryFilePath=/var/tmp
              options nvidia NVreg_UsePageAttributeTable=1
              options nvidia_drm atomic=1
              options nvidia_drm fbdev=1
              options nvidia_drm modeset=1
              options nvidia_modeset debug_force_color_space=13
              options nvidia_modeset disable_hdmi_frl=0
              options nvidia_modeset disable_vrr_memclk_switch=1
              options nvidia_modeset enable_overlay_layers=1
              options nvidia_modeset hdmi_deepcolor=1
              options nvidia_modeset opportunistic_display_sync=1
              options nvidia_modeset output_rounding_fix=1
              options nvidia_modeset vblank_sem_control=1
              options nvidia_uvm uvm_disable_hmm=0
              options nvidia_uvm uvm_enable_va_space_mm=1
              options nvidia_uvm uvm_global_oversubscription=1
              options nvidia_uvm uvm_leak_checker=2
              options nvidia_uvm uvm_page_table_location=vid
              options nvidia_uvm uvm_peer_copy=virt
              options nvidia_uvm uvm_perf_access_counter_batch_count=32
              options nvidia_uvm uvm_perf_access_counter_migration_enable=1
              options nvidia_uvm uvm_perf_access_counter_threshold=100
              options nvidia_uvm uvm_perf_fault_batch_count=64
              options nvidia_uvm uvm_perf_fault_coalesce=1
              options nvidia_uvm uvm_perf_prefetch_enable=1
              options nvidia_uvm uvm_perf_prefetch_min_faults=2
              options nvidia_uvm uvm_perf_prefetch_threshold=4
              options nvidia_uvm uvm_perf_thrashing_enable=0
              options blackmagic blackmagic_flags=4
        options cec debug_phys_addr=1
        options cec debug=2
        options uvcvideo clock=monotonic hwtimestamps=1 nodrop=0
        options v4l2loopback devices=2
        options v4l2loopback video_nr=10,11
        options v4l2loopback devices=4
        options v4l2loopback video_nr=10,11,12,13
        options v4l2loopback card_label="Hyprland Virtual Camera","Hyprland Screen Capture","Iriun Webcam","Iriun Webcam #2"
        options v4l2loopback exclusive_caps=1,1,1,1
        options v4l2loopback max_buffers=4
        options v4l2loopback max_width=3840
        options v4l2loopback max_height=2160
        options v4l2loopback_dc width=640 height=480
        #options video allow_duplicates=0
        #options video brightness_switch_enabled=1
        #options video device_id_scheme=1
        #options video hw_changes_brightness=-1
        #options video only_lcd=0
        #options video report_key_events=3

    '';
    extraModulePackages = with pkgs.linuxPackages_zen; [
      acpi_call
      ajantv2
      akvcam
      batman_adv
      bcc
      bpftrace
      corefreq
      cpupower
      cryptodev
      decklink
      dpdk
      gasket
      ecapture
      ipu6-drivers
      iio-utils
      kvmfr
      msi-ec
      mstflint_access
      new-lg4ff
      nvidia_x11_latest_open
      odp-dpdk
      rtw88
      nullfs
      pktgen
      ply
      r8125
      systemtap
      usbip
      tt-kmd
      v4l2loopback
      vhba
      zfs_unstable
    ];
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "nvidia_drm.modeset=1"
      "nvidia.NVreg_EnableGpuFirmware=0"
      "ibt=off"
      "mds=off"
      "iommu=pt"
      "nouveau.modeset=0"
      "spectre_v2=off"
      "transparent_hugepage=always"
      "numa_balancing=enable"
      "processor.max_cstate=1"
      "intel_idle.max_cstate=0"
      "intel_iommu=on"
      "xe.enable_guc=2"
      "xe.guc_log_level=3"
      "xe.guc_firmware_path=/run/current-system/firmware/i915/tgl_guc_70.bin.zst"
      "xe.huc_firmware_path=/run/current-system/firmware/i915/tgl_huc.bin.zst"
      "xe.enable_dc=4"
      "systemd.mask=systemd-vconsole-setup.service"
      "systemd.mask=dev-tpmrm0.device"
      "nowatchdog"
      "modprobe.blacklist=sp5100_tco"
      "modprobe.blacklist=iTCO_wdt"
    ];
    initrd = {
      availableKernelModules = [
        "xe"
        "xhci_pci"
        "nvidia"
        "nvidia_drm"
        "nvidia_uvm"
        "nvidia_modeset"
        "nvme"
        "usb_storage"
        "usbhid"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "thunderbolt"
        "usb_storage"
        "vmd"
      ];
      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
      luks = {
        cryptoModules = [
          "aes"
          "aes_generic"
          "af_alg"
          "algif_skcipher"
          "blowfish"
          "twofish"
          "serpent"
          "cbc"
          "xts"
          "lrw"
          "sha1"
          "sha256"
          "sha512"
        ];
        devices = {
          "luks-12687fb9-f76f-43ac-b533-026bfdce81cf" = {
            device = "/dev/disk/by-uuid/12687fb9-f76f-43ac-b533-026bfdce81cf";
          };
          "luks-dca3eed4-ed64-4a7a-b60e-41ca418662c4" = {
            device = "/dev/disk/by-uuid/dca3eed4-ed64-4a7a-b60e-41ca418662c4";
          };
        };
      };
      kernelModules = [
        "xe"
        "nvidia"
        "nvidia_drm"
        "nvidia_uvm"
        "nvidia-modeset"
        "kvm-intel"
        "cpufreq_ondemand"
        "cpufreq_performance"
        "vfio-pci"
        "ahci"
        "mlx4_core"
        "mlx4_en"
        "ib_core"
        "ib_qib"
        "vfio-pci"
        "vfio"
        "vfio_iommu_type1"
        "r8125"
        "mlx4_core"
        "mlx4_en"
        "ib_core"
        "ib_qib"
        "msr"
        "rapl"
        "v4l2loopback"
      ];
    };
    kernel = {
      sysctl = {
        "fs.aio-max-nr" = 1048576;
        "fs.file-max" = 200000;
        "fs.inotify.max_user_watches" = 524288;
        "fs.nr_open" = 2097152;
        "kernel.numa_balancing" = 1;
        "kernel.pid_max" = 131072;
        "kernel.randomize_va_space" = 2;
        "kernel.sched_autogroup_enabled" = 0;
        "kernel.sched_latency_ns" = 6000000;
        "kernel.sched_migration_cost_ns" = 500000;
        "kernel.sched_rt_runtime_us" = -1;
        "kernel.shmall" = 1048576;
        "kernel.shmmax" = 4294967296;
        "kernel.shmmni" = 4096;
        "kernel.threads-max" = 524288;
        "net.core.rmem_max" = 268435456;
        "net.core.wmem_max" = 268435456;
        "net.core.netdev_budget" = 600;
        "net.core.netdev_max_backlog" = 5000;
        "net.core.optmem_max" = 65536;
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv4.conf.all.log_martians" = 1;
        "net.ipv4.conf.all.rp_filter" = 1;
        "net.ipv4.conf.default.accept_source_route" = 0;
        "net.ipv4.conf.default.rp_filter" = 1;
        "net.ipv4.conf.default.log_martians" = 1;
        "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
        "net.ipv4.tcp_fastopen" = 3;
        "net.ipv4.tcp_fin_timeout" = 15;
        "net.ipv4.tcp_rmem" = "4096 87380 16777216";
        "net.ipv4.tcp_wmem" = "4096 65536 16777216";
        "net.ipv4.tcp_window_scaling" = 1;
        "net.ipv4.tcp_congestion_control" = "bbr";
        "vm.dirty_background_ratio" = 10;
        "vm.dirty_expire_centisecs" = 3000;
        "vm.dirty_ratio" = 20;
        "vm.max_map_count" = 2147483642;
        "vm.min_free_kbytes" = 65536;
        "vm.swappiness" = 10;
      };
    };
    tmp = {
      cleanOnBoot = true;
      tmpfsSize = "25%";
      tmpfsHugeMemoryPages = "always";
      useZram = true;
      zramSettings = {
        compression-algorithm = "zstd";
        fs-type = "ext4";
      };
    };
    modprobeConfig.enable = true;
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/cb629670-0921-426c-a0dc-e294516476f5";
      fsType = "ext4";
      options = [ "x-initrd.mount" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/8EF3-07B2";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };
  swapDevices = [
    { device = "/dev/disk/by-uuid/9675768b-21c9-4bf4-885a-261a3b520189"; }
  ];
}

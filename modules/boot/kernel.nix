# /qompassai/NixOS/modules/boot/kernel.nix
# Qompass AI Nix kernel configuration module
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.system.kernel;
in {
  options.system.kernel = {
    enable = mkEnableOption "Enable custom kernel configuration";
    enablePerformance = mkOption {
      type = types.bool;
      default = true;
      description = "Enable performance optimizations";
    };
    enableQuantumSupport = mkOption {
      type = types.bool;
      default = true;
      description = "Enable quantum computing support";
    };
  };
  config = mkIf cfg.enable {
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      kernelParams =
        [
          "mitigations=off"
          "spectre_v2=off"
          "spec_store_bypass_disable=off"
          "tsx_async_abort=off"
          "mds=off"
          "l1tf=off"
          "noibrs"
          "noibpb"
          "nopti"
          "nospectre_v1"
          "nospectre_v2"
          "nosmt"
          "transparent_hugepage=always"
          "numa_balancing=enable"
          "processor.max_cstate=1"
          "intel_idle.max_cstate=0"
          "idle=poll"
          "elevator=mq-deadline"
          "scsi_mod.use_blk_mq=1"
          "lockdown=off"
          "iommu=pt"
          "intel_iommu=on"
          "amd_iommu=on"
          "workqueue.power_efficient=0"
          "rcu_nocbs=0-7"
          "isolcpus=nohz,domain,managed_irq,8-15"
        ]
        ++ optionals cfg.enableQuantumSupport [
          "quantum.enable_native=1"
          "preempt=full"
        ];
      kernelModules =
        [
          "kvm-intel"
          "kvm-amd"
          "vfio-pci"
          "vfio"
          "vfio_iommu_type1"
          "r8125"
          "mlx4_core"
          "mlx4_en"
          "ib_core"
          "ib_qib"
          "cpufreq_ondemand"
          "cpufreq_performance"
          "msr"
          "rapl"
        ]
        ++ optionals cfg.enableQuantumSupport [
          "quantum_simulator"
          "qiskit_runtime"
        ];
      kernel.sysctl = {
        "net.core.rmem_max" = 268435456;
        "net.core.wmem_max" = 268435456;
        "net.core.netdev_max_backlog" = 30000;
        "net.core.netdev_budget" = 600;
        "vm.swappiness" = 10;
        "vm.dirty_ratio" = 15;
        "vm.dirty_background_ratio" = 5;
        "vm.vfs_cache_pressure" = 50;
        "kernel.sched_migration_cost_ns" = 5000000;
        "kernel.sched_autogroup_enabled" = 0;

        "kernel.numa_balancing" = 1;
        "kernel.sched_rt_runtime_us" = -1;
      };
    };
  };
}

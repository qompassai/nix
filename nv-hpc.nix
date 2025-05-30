# ~/.GH/Qompass/NixOS/modules/0/nv-hpc.nix
# ----------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.development.nvidia-hpc;
in {
  options.development.nvidia-hpc = {
    enable = mkEnableOption "Enable NVIDIA HPC SDK";
    enableCompilers = mkOption {
      type = types.bool;
      default = true;
      description = "Enable NVIDIA HPC compilers (nvc, nvc++, nvfortran)";
    };
    enableCommunication = mkOption {
      type = types.bool;
      default = true;
      description = "Enable communication libraries (NCCL, NVSHMEM, MPI)";
    };
    enableProfiling = mkOption {
      type = types.bool;
      default = true;
      description = "Enable profiling tools (Nsight Compute, Nsight Systems)";
    };
    enableExamples = mkOption {
      type = types.bool;
      default = false;
      description = "Install HPC SDK examples";
    };
    setAsDefault = mkOption {
      type = types.bool;
      default = false;
      description = "Set NVIDIA compilers as default C/C++/Fortran compilers";
    };
  };
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.drivers.nvidia.enable or false;
        message = "NVIDIA HPC SDK requires NVIDIA drivers to be enabled";
      }
    ];
    environment.systemPackages = with pkgs;
      [
        nvidia-hpc-sdk
      ]
      ++ optionals cfg.enableCommunication [
        openmpi-nvidia
        nccl-hpc
        nvshmem-hpc
      ]
      ++ optionals cfg.enableProfiling [
      ];
    environment.sessionVariables = {
      NVHPC_ROOT = "${pkgs.nvidia-hpc-sdk}";
      NVHPC_CUDA_HOME = "${pkgs.nvidia-hpc-sdk}/cuda";
      PATH = mkBefore ["${pkgs.nvidia-hpc-sdk}/bin"];
      LD_LIBRARY_PATH = mkBefore [
        "${pkgs.nvidia-hpc-sdk}/compilers/lib"
        "${pkgs.nvidia-hpc-sdk}/cuda/lib64"
        "${pkgs.nvidia-hpc-sdk}/math_libs/lib64"
      ];
      CC = mkIf cfg.setAsDefault "${pkgs.nvidia-hpc-sdk}/bin/nvc";
      CXX = mkIf cfg.setAsDefault "${pkgs.nvidia-hpc-sdk}/bin/nvc++";
      FC = mkIf cfg.setAsDefault "${pkgs.nvidia-hpc-sdk}/bin/nvfortran";
      CUDA_ROOT = "${pkgs.nvidia-hpc-sdk}/cuda";
      CUDA_HOME = "${pkgs.nvidia-hpc-sdk}/cuda";
      CUDA_PATH = "${pkgs.nvidia-hpc-sdk}/cuda";
      MPI_ROOT = mkIf cfg.enableCommunication "${pkgs.nvidia-hpc-sdk}/comm_libs/mpi";
      MPICC = mkIf cfg.enableCommunication "${pkgs.nvidia-hpc-sdk}/bin/mpicc";
      MPICXX = mkIf cfg.enableCommunication "${pkgs.nvidia-hpc-sdk}/bin/mpicxx";
      MPIF90 = mkIf cfg.enableCommunication "${pkgs.nvidia-hpc-sdk}/bin/mpif90";
      NCCL_ROOT = mkIf cfg.enableCommunication "${pkgs.nccl-hpc}";
      NSIGHT_COMPUTE_ROOT = mkIf cfg.enableProfiling "${pkgs.nvidia-hpc-sdk}/profilers/Nsight_Compute";
      NSIGHT_SYSTEMS_ROOT = mkIf cfg.enableProfiling "${pkgs.nvidia-hpc-sdk}/profilers/Nsight_Systems";
    };
    environment.etc."nvidia-hpc-cmake.cmake".text = ''
      # NVIDIA HPC SDK CMake configuration
      set(CMAKE_C_COMPILER "${pkgs.nvidia-hpc-sdk}/bin/nvc")
      set(CMAKE_CXX_COMPILER "${pkgs.nvidia-hpc-sdk}/bin/nvc++")
      set(CMAKE_Fortran_COMPILER "${pkgs.nvidia-hpc-sdk}/bin/nvfortran")
      set(CUDA_TOOLKIT_ROOT_DIR "${pkgs.nvidia-hpc-sdk}/cuda")
      set(NVHPC_ROOT "${pkgs.nvidia-hpc-sdk}")

      link_directories("${pkgs.nvidia-hpc-sdk}/compilers/lib")
      link_directories("${pkgs.nvidia-hpc-sdk}/cuda/lib64")
      link_directories("${pkgs.nvidia-hpc-sdk}/math_libs/lib64")
    '';
    programs.bash.interactiveShellInit = mkIf cfg.enable ''
      # NVIDIA HPC SDK activation
      if [ -f ${pkgs.nvidia-hpc-sdk}/activate ]; then
        source ${pkgs.nvidia-hpc-sdk}/activate
      fi
    '';
    programs.zsh.interactiveShellInit = mkIf cfg.enable ''
      # NVIDIA HPC SDK activation
      if [ -f ${pkgs.nvidia-hpc-sdk}/activate ]; then
        source ${pkgs.nvidia-hpc-sdk}/activate
      fi
    '';
    environment.etc = mkIf cfg.enableExamples {
      "nvidia-hpc-examples" = {
        source = "${pkgs.nvidia-hpc-sdk}/examples";
      };
    };
  };
}

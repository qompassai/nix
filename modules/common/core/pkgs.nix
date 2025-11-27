{
  pkgs,
  platform,
  system ? pkgs.system,
  cpuType ? null, # "intel", "amd", "apple", "arm", etc.
  gpuType ? null, # "nvidia", "amd", "intel", "apple", etc.
}:
let
  basePkgs = with pkgs; [
    curl
    git
    htop
    openssh
  ];
  packageTable = {
    "linux-x86_64-linux" = with pkgs; [
      lsof
      strace
      gcc
      nvtop
    ];
    "linux-aarch64-linux" = with pkgs; [
      linuxFirmware
      lsof
      gcc
      strace
    ];
    "linux-i686-linux" = with pkgs; [
      gcc
      lsof
      strace

    ];
    "darwin-x86_64-darwin" = with pkgs; [
      coreutils
      tmux
      gcc
    ];
    "darwin-aarch64-darwin" = with pkgs; [
      coreutils
      gcc
      tmux
      mtr
    ];
    "nvidia-aarch64-linux" = with pkgs; [
      cudaPackages.cudatoolkit
      gcc
      linuxFirmware
    ];
    "vm-x86_64-linux" = with pkgs; [
      qemu
    ];
  };
  key = "${platform}-${system}";
  cpuPkgs =
    with pkgs;
    if cpuType == "intel" then
      [ intel-media-driver ]
    else if cpuType == "amd" then
      [ amdvlk ]
    else if cpuType == "apple" then
      [ ]
    else if cpuType == "arm" then
      [ ]
    else
      [ ];
  gpuPkgs =
    with pkgs;
    if gpuType == "nvidia" then
      [
        nvidia_x11
        nvidia-settings
        nvtop
      ]
    else if gpuType == "amd" then
      [
        mesa
        drm_info
      ]
    else if gpuType == "intel" then
      [ intel-gpu-tools ]
    else if gpuType == "apple" then
      [ ]
    else
      [ ];
  uniquePkgs = if packageTable ? key then packageTable.${key} else [ ];
in
basePkgs ++ uniquePkgs ++ cpuPkgs ++ gpuPkgs

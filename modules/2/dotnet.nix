# ~/.GH/Qompass/NixOS/modules/2/dotnet.nix
# ----------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ config, lib, pkgs, ... }:
let
  cfg = config.programming.dotnet;
  inherit (lib) mkEnableOption mkOption types mkIf optionals;
in {
  options.programming.dotnet = {
    enable = mkEnableOption "Enable .NET SDKs";
    versions = mkOption {
      type = types.listOf (types.enum [ "6.0" "8.0" "9.0" ]);
      default = [ "8.0" ];
      description = "Which .NET SDK versions to install";
    };
    withMono = mkEnableOption "Include Mono runtime for legacy projects";
    withNeovim = mkEnableOption "Neovim integration with omnisharp and formatting tools";
  };

  config = mkIf cfg.enable (let
    sdkMap = {
      "6.0" = pkgs.dotnet-sdk_6;
      "8.0" = pkgs.dotnet-sdk_8;
      "9.0" = pkgs.dotnet-sdk_9;
    };

    selectedSdks = map (v: sdkMap.${v}) cfg.versions;

    omnisharpWrapper = pkgs.writeShellScriptBin "omnisharp-wrapper" ''
      ${pkgs.omnisharp-roslyn}/bin/OmniSharp --languageserver
    '';

    neovimDotnetWrapper = pkgs.wrapNeovim pkgs.neovim-nightly {
      configure = {
        packages.myPlugins = with pkgs.vimPlugins; [ omnisharp-vim ];
        customRC = ''
          let g:OmniSharp_server_use_net6 = 1
          autocmd FileType cs setlocal omnifunc=OmniSharp#Complete
        '';
      };
    };
  in {
    environment.systemPackages =
      selectedSdks
      ++ optionals cfg.withMono [ pkgs.mono ]
      ++ optionals cfg.withNeovim [ omnisharpWrapper neovimDotnetWrapper ];

    environment.variables = {
      DOTNET_CLI_TELEMETRY_OPTOUT = "1";
      DOTNET_NOLOGO = "1";
    };

    programs.neovim = mkIf cfg.withNeovim {
      enable = true;
      package = neovimDotnetWrapper;
      extraPackages = with pkgs; [
        csharp-ls
        netcoredbg
        omnisharp-roslyn
      ];
    };
  });
}


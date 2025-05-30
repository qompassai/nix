# /qompassai/nix/modules/2/go.nix
# ------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ config, lib, pkgs, ... }:
let
  cfg = config.programming.go;
  inherit (cfg) version tools zigSupport llvmVersion;
  inherit (lib) optionals;
  inherit (pkgs) zig llvmPackages_17 llvmPackages_18;

  versions = {
     inherit (pkgs) go_1_21 go_1_22 go_1_23;
  };
in {
  options.programming.go = {
    enable = lib.mkEnableOption "Go development environment";
    version = lib.mkOption {
      type = lib.types.enum (builtins.attrNames versions);
      default = "go_1_23";
    };
    tools = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        gopls
        delve
        golangci-lint
        go-tools
        gomodifytags
        gotests
      ];
    };
    zigSupport = lib.mkEnableOption "Zig-based cross-compilation";
    llvmVersion = lib.mkOption {
      type = lib.types.enum [ "llvm_17" "llvm_18" ];
      default = "llvm_17";
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      variables = {
        GOPATH = "$HOME/.go";
        GOBIN = "$HOME/.go/bin";
        GO111MODULE = "on";
        GOPROXY = "https://proxy.golang.org,direct";
        GOSUMDB = "sum.golang.org";
      };
      sessionVariables = rec {
        PATH = [ "$GOBIN" ];
      };
    };

    home.packages = 
      [ versions.${version} ] 
      ++ tools                 
      ++ optionals zigSupport [ zig ]
      ++ optionals (llvmVersion == "llvm_17") [ llvmPackages_17.clang ]
      ++ optionals (llvmVersion == "llvm_18") [ llvmPackages_18.clang ];

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    nix.shellHook = ''
      go_cross() {
        case "$1" in
          "simple")
            export GOOS="$2"
            export GOARCH="$3"
            export CGO_ENABLED=0
            ;;
          "zig")
            export CC="${zig}/bin/zig cc -target $2-$3"
            export CXX="${zig}/bin/zig c++ -target $2-$3"
            export CGO_ENABLED=1
            ;;
        esac
      }
    '';
  };
}


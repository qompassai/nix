# /qompassai/nix/modules/2/ocaml.nix
# ---------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ config, lib, pkgs, ... }:
let
  cfg = config.programming.ocaml;
  inherit (lib) mkEnableOption mkOption types;
in {
  options.programming.ocaml = {
    enable = mkEnableOption "OCaml development environment";
    compiler = mkOption {
      type = types.enum [ "system" "5.1" "5.2" "4.14" ];
      default = "system";
      description = "OCaml compiler version";
    };
    enableOpam = mkEnableOption "Opam package manager integration";
  };

  config = lib.mkIf cfg.enable (let
    ocamlPackages = pkgs.ocaml-ng."ocamlPackages_${replaceStrings ["."] ["_"] cfg.compiler}" 
      or pkgs.ocaml-ng.ocamlPackages;

    opamInitScript = pkgs.writeScript "opam-init.sh" ''
      #!${pkgs.bash}/bin/bash
      export OPAMROOT="${config.xdg.configHome}/opam"
      if command -v opam &> /dev/null; then
        if [[ ! -d "$OPAMROOT" ]]; then
          opam init --no-setup --disable-sandboxing --yes
        fi
        eval $(opam env)
      fi
    '';
  in {
    environment.systemPackages = with ocamlPackages; [
      ocaml
      dune_3
      ocaml-lsp
      ocamlformat
      utop
    ] ++ lib.optionals cfg.enableOpam [ pkgs.opam ];

    environment.variables = {
      OCAMLRUNPARAM = "b";
      OCAMLFORMAT_PROFILE = "conventional";
      DUNE_CACHE = "enabled";
      MANPATH = "${ocamlPackages.ocaml}/share/man:$MANPATH";
    };

    home.file.".ocamlformat".text = ''
      profile = conventional
      break-cases = all
      margin = 80
    '';

    programs.bash.shellInit = lib.optionalString cfg.enableOpam ''
      source ${opamInitScript}
    '';

    xdg.configFile."ocaml/nix-ocaml.conf".text = ''
      let nix_ocaml_libs = "${ocamlPackages.ocaml}/lib/ocaml"
    '';
  });
}

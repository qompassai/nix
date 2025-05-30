# /qompassai/nix/modules/2/lua.nix
# Nix Lua Module
# -------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programming.lua;
  inherit (lib) types mkEnableOption mkOption optionals;
in {
  options.programming.lua = {
    enable = mkEnableOption "Lua development environment";
    version = mkOption {
      type = types.enum ["5.1" "5.2" "5.3" "5.4" "luajit" "openresty" "mlua"];
      default = "5.1";
    };
    withNeovim = mkEnableOption "Neovim nightly integration";
    luarocksConfig = mkOption {
      type = types.path;
      default = "${config.xdg.configHome}/luarocks";
    };
  };
  config = lib.mkIf cfg.enable (let
    luaPkg =
      {
        "5.1" = pkgs.lua5_1;
        "5.2" = pkgs.lua5_2;
        "5.3" = pkgs.lua5_3;
        "5.4" = pkgs.lua5_4;
        "luajit" = pkgs.luajit;
        "openresty" = pkgs.openresty-lua;
        "mlua" = pkgs.lua.overrideAttrs (old: {
          pname = "mlua";
          version = "custom";
        });
      }.${
        cfg.version
      };
    ver_num =
      if cfg.version == "luajit"
      then "5.1"
      else cfg.version;
    neovimWrapper = pkgs.wrapNeovim pkgs.neovim-nightly {
      configure = {
        customRC = ''
          lua << EOF
          package.path = vim.fn.stdpath("data").."/lua/${ver_num}/?.lua;"..package.path
          EOF
        '';
      };
    };
  in {
    environment.systemPackages =
      [luaPkg]
      ++ optionals cfg.withNeovim [neovimWrapper];
    environment.variables = {
      LUA_DEBUG_PARAMS = "-e 'require(\"mobdebug\").start()'";
      FZF_DEFAULT_OPTS = "--layout=reverse --inline-info";
      FZF_DEFAULT_COMMAND = "fd --type f --strip-cwd-prefix";
      LUA_PATH = "${cfg.luarocksConfig}/share/lua/${ver_num}/?.lua;...";
      LUA_CPATH = "${cfg.luarocksConfig}/lib/lua/${ver_num}/?.so;;";
      LUA_INIT = "@${config.xdg.configHome}/lua/init.lua";
    };
    xdg.configFile."luarocks/config-${ver_num}.lua".text = ''
      rocks_trees = {
        { name = "user", root = "${cfg.luarocksConfig}" }
      }
      lua_interpreter = "${luaPkg}/bin/${
        if cfg.version == "luajit"
        then "luajit"
        else "lua"
      }";
      variables = {
        LUA_BINDIR = "${luaPkg}/bin";
        LUA_INCDIR = "${luaPkg}/include";
        LUA_LIBDIR = "${luaPkg}/lib";
      }
    '';
    programs.neovim = lib.mkIf cfg.withNeovim {
      enable = true;
      package = neovimWrapper;
      extraPackages = with pkgs; [
        lua-language-server
        luaformatter
      ];
    };
  });
}

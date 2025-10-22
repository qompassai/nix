# i18n.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  platform,
  system ? null,
  locale ? "en_US.UTF-8",
  inputMethodType ? "fcitx5",
}:
let
  baseI18n = {
    defaultLocale = locale;
    extraLocaleSettings = {
      LC_ADDRESS = locale;
      LC_IDENTIFICATION = locale;
      LC_MEASUREMENT = locale;
      LC_MONETARY = locale;
      LC_NAME = locale;
      LC_NUMERIC = locale;
      LC_PAPER = locale;
      LC_TELEPHONE = locale;
      LC_TIME = locale;
    };
    inputMethod = {
      enable = true;
      type = inputMethodType;
      fcitx5 = {
        waylandFrontend = true;
        settings = {
          globalOptions = { };
        };
      };
    };
  };
  i18nTable = {
    "darwin-x86_64-darwin" = {
      defaultLocale = "en_GB.UTF-8";
      extraLocaleSettings.LC_TIME = "en_GB.UTF-8";
      inputMethod.enable = false;
    };
    "linux-aarch64-linux" = {
      inputMethod = {
        type = "ibus";
        ibus = {
          useXWayland = true;
        };
      };
    };
  };
  key = "${platform}-${system}";
  uniqueI18n = if i18nTable ? key then baseI18n // i18nTable.${key} else baseI18n;
in
{
  i18n = uniqueI18n;
}

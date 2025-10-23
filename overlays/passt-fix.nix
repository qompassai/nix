# passt-fix.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
self: super: {
  passt = super.stdenv.mkDerivation {
    pname = "passt-fixed";
    version = "disabled";
    dontBuild = true;
    dontInstall = true;
    meta = {
      description = "Passt disabled because of maintainer bug";
      maintainers = [];
      license = super.lib.licenses.mit;
    };
  };
}

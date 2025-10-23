# default.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
self: super: {
  cmake = super.cmake.overrideAttrs (oldAttrs: {
    buildFlagsArray = (oldAttrs.buildFlagsArray or [ "-arch=Gen9" ] ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
buildPhase = ''
export IGC_ARCH=Gen 9
make
'';
  });
}

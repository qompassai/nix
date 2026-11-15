# /qompassai/nixos/overlays/x86_64.nix
# Qompass AI NixOS x86_64 Overlay
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
final: super: {
  stdenv =
    super.llvmPackages.stdenv.withCFlags
      [
        "-march=x86-64-v3"
        "-mtune=native"
        "-O2"
        "-pipe"
        "-fno-plt"
        "-fexceptions"
        "-Wp,-D_FORTIFY_SOURCE=3"
        "-Wformat"
        "-fstack-clash-protection"
        "-fcf-protection"
        "-fno-omit-frame-pointer"
        "-mno-omit-leaf-frame-pointer"
      ]
      .withLdFlags
      [
        "-Wl,-O2"
        "-Wl,--sort-common"
        "-Wl,--as-needed"
        "-Wl,-z,relro"
        "-Wl,-z,now"
        "-Wl,-z,pack-relative-relocs"
        "-fuse-ld=mold"
      ]
      super.llvmPackages.stdenv;
  buf = super.buf.overrideAttrs (old: {
    doCheck = false;
  });
  passt = super.passt.overrideAttrs (old: {
    meta = old.meta // {
      maintainers = [ ];
    };
  });
  python3Packages = super.python3Packages // {
    portalocker = super.python3Packages.portalocker.overrideAttrs (_: {
      doCheck = false;
    });
    virtualenv = super.python3Packages.virtualenv.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    });
  };
  python311Packages = super.python311Packages // {
    portalocker = super.python311Packages.portalocker.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    });
  };
  python312Packages = super.python312Packages // {
    portalocker = super.python312Packages.portalocker.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    });
  };
  python313Packages = super.python313Packages // {
    portalocker = super.python313Packages.portalocker.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    });
  };
  bison = super.bison.overrideAttrs (old: {
    buildPhase = builtins.trace "BISON OVERLAY APPLIED" (old.buildPhase or "");
    doCheck = false;
    doInstallCheck = false;
    NIX_CFLAGS_COMPILE =
      toString [
        "-Wno-return-local-addr"
        "-Wno-cpp"
      ]
      + (old.NIX_CFLAGS_COMPILE or "");
    meta = {
      broken = false;
    };
  });
  bison_32 = super.bison_32.overrideAttrs (old: {
    doCheck = false;
    doInstallCheck = false;
  });
  brotli = super.brotli.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  curl_impersonate = super.curl_impersonate.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  curl_impersonate_ff = super.curl_impersonate_ff.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  dcgm = super.dcgm.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  firmware-manager = super.firmware-manager.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ super.xz ];
    PKG_CONFIG_PATH = "${super.xz.dev}/lib/pkgconfig";
  });
  hyprland = super.hyprland.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  leatherman = super.leatherman.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  properties-cpp = super.properties-cpp.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  nvidia-texture-tools = super.nvidia-texture-tools.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  openvino = super.openvino.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  swiftshader = super.swiftshader.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
}

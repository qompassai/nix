# /qompassai/nixos/overlays/x86_64.nix
# Qompass AI NixOS x86_64 Overlay
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
final: prev: {
  stdenv =
    prev.llvmPackages.stdenv.withCFlags
      [
        "-march=x86-64-v3"
        "-mtune=native"
        "-O2"
        "-pipe"
        "-fno-plt"
        "-fexceptions"
        "-Wp,-D_FORTIFY_SOURCE=3"
        "-Wformat"
        "-Werror=format-security"
        "-fstack-clash-protection"
        "-fcf-protection"
        "-fno-omit-frame-pointer"
        "-mno-omit-leaf-frame-pointer"
      ]
      .withLdFlags
      [
        "-Wl,-O1"
        "-Wl,--sort-common"
        "-Wl,--as-needed"
        "-Wl,-z,relro"
        "-Wl,-z,now"
        "-Wl,-z,pack-relative-relocs"
        "-fuse-ld=mold"
      ]
      prev.llvmPackages.stdenv;
  sccacheWrapper = prev.sccacheWrapper;
  buf = prev.buf.overrideAttrs (old: {
    doCheck = false;
  });
  passt = prev.passt.overrideAttrs (old: {
    meta = old.meta // {
      maintainers = [ ];
    };
  });
  python3Packages = prev.python3Packages // {
    portalocker = prev.python3Packages.portalocker.overrideAttrs (_: {
      doCheck = false;
    });
  };
  python311Packages = prev.python311Packages // {
    portalocker = prev.python311Packages.portalocker.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    });
  };
  python312Packages = prev.python312Packages // {
    portalocker = prev.python312Packages.portalocker.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    });
  };
  python313Packages = prev.python313Packages // {
    portalocker = prev.python313Packages.portalocker.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    });
  };
  bison = prev.bison.overrideAttrs (_: {
    doCheck = false;
  });
  brotli = prev.brotli.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  curl-impersonate = prev.curl-impersonate.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  curl-impersonate-ff = prev.curl-impersonate-ff.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  dcgm = prev.dcgm.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  firmware-manager = prev.firmware-manager.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ final.xz ];
    PKG_CONFIG_PATH = "${final.xz.dev}/lib/pkgconfig";
  });
  hyprland = prev.hyprland.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  leatherman = prev.leatherman.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  properties-cpp = prev.properties-cpp.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  nvidia-texture-tools = prev.nvidia-texture-tools.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  openvino = prev.openvino.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  swiftshader = prev.swiftshader.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
}

self: super: {
  intel-graphics-compiler = super.intel-graphics-compiler.overrideAttrs (oldAttrs: {
    buildFlagsArray = (oldAttrs.buildFlagsArray or [ "-arch=Gen9" ] ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" "-DIGC_OPTION_ARCHITECTURE_TARGET=Gen9"]);
buildPhase = ''
export IGC_ARCH=Gen 9
export IGC_OPTION__ARCHITECTURE_TARGET=Gen9
make
'';
  });
} 

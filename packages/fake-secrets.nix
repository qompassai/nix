# fake-secrets.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  runCommandNoCC,
  jq,
  fd,
  make-fake-secrets,
}:
runCommandNoCC "fake-secrets"
  {
    nativeBuildInputs = [
      jq
      fd
      make-fake-secrets
    ];
    src = ../secrets;
  }
  ''
    cd "$src"
    fd '\.yaml$' --exec make-fake-secrets "{}" "$out/{}"
  ''

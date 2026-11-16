# Secrets provisioning

primo.yaml contains only encrypted PLACEHOLDER values, never usable credentials.
Before deployment, Matt must replace both values with password hashes using sops.
Until then activation cannot supply valid login hashes. No plaintext fallback exists.

The .sops.yaml recipient was converted by ssh-to-age from primo's local
/etc/ssh/ssh_host_ed25519_key.pub. Verify that this is also the deployed machine's
public host key before provisioning; rekey if the installed NixOS key differs.
sops-nix converts /etc/ssh/ssh_host_ed25519_key at activation, before creating users.
Keep the host private key outside this repository and available on the target.

Use an administrator age identity as an additional recipient before managing real
values: host-only encryption requires access to the host key for future edits.
No ARM recipient is defined because armhost is retired.

Authenticated GitHub fetching is disabled. Public inputs work without a PAT.
lib/mkSystem.nix is absent: the unused SSD helper with a plaintext fallback was
not imported. The live users use sops password hash files exclusively.

## ds920plus.yaml

Placeholder only, landed with the DS920+ host module under D-1600
(2026-11-16). It was encrypted to a THROWAWAY age recipient whose private
key was destroyed at creation time, so its values are unrecoverable by
design and the file must never be treated as decryptable. At install time:
derive the real recipient from the DS920+'s own SSH host key with
ssh-to-age, replace the ds920plus anchor and creation rule in .sops.yaml,
and recreate this file with real password hashes before storing any real
value in it.

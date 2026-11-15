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

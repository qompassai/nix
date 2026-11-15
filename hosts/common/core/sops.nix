# Local secrets, decrypted with the machine's SSH host key.
{ config, inputs, username, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];
  sops = {
    defaultSopsFile = ../../../secrets/primo.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      user-password-hash.neededForUsers = true;
      root-password-hash.neededForUsers = true;
    };
  };
  users.users.${username}.hashedPasswordFile = config.sops.secrets.user-password-hash.path;
  users.users.root.hashedPasswordFile = config.sops.secrets.root-password-hash.path;
}

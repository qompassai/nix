#/etc/nixos/configuration.nix
{ ... }:
{
  imports = [
    ./hosts/linux/x86_64/config.nix
  ];
}

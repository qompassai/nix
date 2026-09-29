# Example: add repomap to any repo's flake.
#
# Copy this into your repo's flake.nix (merge the inputs/outputs with your
# own), add `.repomap.txt` to your .gitignore, and every `nix develop` /
# direnv entry keeps $PWD/.repomap.txt fresh.
{
  description = "example repo with repomap";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    repomap.url = "github:qompassai/nix?dir=repomap";
  };

  outputs = { self, nixpkgs, flake-utils, repomap }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in {
        devShells.default = pkgs.mkShell {
          packages = [ repomap.packages.${system}.repomap ];
          shellHook = repomap.lib.refreshHook {
            pkg = repomap.packages.${system}.repomap;
            # budget = 15000;      # ranked-map char budget (default 15000)
            # out = ".repomap.txt"; # output file name (default .repomap.txt)
          };
        };
      });
}

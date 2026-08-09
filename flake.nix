{
  description = "tiago's NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Aseprite is built locally (no public binary substitute). Pin its package
    # set so routine unstable updates do not trigger another long compilation.
    nixpkgs-aseprite.url = "github:NixOS/nixpkgs/e7a3ca8092b61ff85b6a45bf863ea2b2d6a661b3";
    planner.url = "github:tiagohierath/small-navy-planner";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-aseprite, planner, ... }:
  let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-aseprite = import nixpkgs-aseprite {
      inherit system;
      config.allowUnfree = true;
    };
    planit = planner.packages.${system}.default;  # the `planit` command
  in {
    nixosConfigurations.tiago = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit pkgs-unstable pkgs-aseprite planit; };
      modules = [ ./configuration.nix ];
    };
  };
}

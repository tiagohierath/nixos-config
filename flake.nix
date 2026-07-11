{
  description = "tiago's NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    planner.url = "github:tiagohierath/small-navy-planner";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, planner, ... }:
  let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    planit = planner.packages.${system}.default;  # the `planit` command
  in {
    nixosConfigurations.tiago = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit pkgs-unstable planit; };
      modules = [ ./configuration.nix ];
    };
  };
}

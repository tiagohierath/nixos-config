{
  description = "tiago's NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    planner.url = "github:tiagohierath/small-navy-planner";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, planner, ... }:
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
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
          home-manager.users.tiago.imports = [ ./home/tiago.nix ./theme.nix ];
        }
      ];
    };
  };
}

{
  description = "nix-configurations";

  inputs = {
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:nix-community/stylix";
  };

  outputs =
    {
      self,
      agenix,
      home-manager,
      nix-darwin,
      stylix,
      nixpkgs,
      ...
    }@inputs:
    let
      globalModules = [
        {
          system.configurationRevision = self.rev or self.dirtyRev or null;
        }
        ./modules/global/global.nix
      ];
      globalModulesNixos = globalModules ++ [
        ./modules/global/nixos.nix
        home-manager.nixosModules.default
        agenix.nixosModules.default
        stylix.nixosModules.stylix
      ];
      globalModulesMacos = globalModules ++ [
        ./modules/global/macos.nix
        home-manager.darwinModules.default
        agenix.darwinModules.default
        stylix.darwinModules.stylix
      ];
    in
    {
      nixosConfigurations = {
        neurowarp = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = globalModulesNixos ++ [ ./hosts/neurowarp/configuration.nix ];
        };
        ultracore = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = globalModulesNixos ++ [ ./hosts/ultracore/configuration.nix ];
        };
      };
      darwinConfigurations = {
        hackinfrost = nix-darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = globalModulesMacos ++ [ ./hosts/hackinfrost/configuration.nix ];
        };
        forte = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = globalModulesMacos ++ [ ./hosts/forte/configuration.nix ];
        };
      };
    };
}

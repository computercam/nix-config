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
      agenix,
      home-manager,
      nix-darwin,
      stylix,
      ...
    }:
    {
      nixosPresets.global = [
        ./modules/global/global.nix
        ./modules/global/nixos.nix
        home-manager.nixosModules.default
        agenix.nixosModules.default
        stylix.nixosModules.stylix
      ];

      darwinPresets.global = [
        ./modules/global/global.nix
        ./modules/global/macos.nix
        home-manager.darwinModules.default
        agenix.darwinModules.default
        stylix.darwinModules.stylix
      ];
    };
}
````

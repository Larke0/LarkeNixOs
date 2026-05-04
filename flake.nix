{
	description = "LarkeOS config";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    helium = {
      url = "github:AlvaroParker/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
		home-manager = {
			url = "github:nix-community/home-manager/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		larke-shell = {
			url = "github:Larke0/Larke-shell";
			flake = false;
		};

    zen-browser = {
        url = "github:youwen5/zen-browser-flake";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
	};

  outputs = inputs@{ self, nixpkgs, home-manager, nix-flatpak, ... }:
  let
    system = "x86_64-linux";
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    mkHost = hostname: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs pkgs-unstable; };
      modules = [
        ./${hostname}/hardware-configuration.nix
        ./configuration.nix
        ./${hostname}/configuration.nix
        ./modules/conda.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.larke = import ./home.nix;
            backupFileExtension = "backup";
            extraSpecialArgs = { inherit inputs; };
            sharedModules = [
              inputs.nix-flatpak.homeManagerModules.nix-flatpak
            ];
          };
        }
      ];
    };
  in {
    nixosConfigurations = {
      kohaku = mkHost "kohaku";
      suika  = mkHost "suika";
    };
  };
}

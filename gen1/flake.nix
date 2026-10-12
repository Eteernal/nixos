# /etc/nixos/flake.nix
{
  description = "NixOS flake with stable and unstable branches.";

  inputs = {
    # 1. Główny stabilny system (zgodny z Twoim 26.05)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # 2. Źródło najnowszych pakietów (dla przeglądarek, VS Code)
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # 3. Spicetify
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs-unstable"; 
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, spicetify-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      
      # Konfiguracja pakietów unstable, pozwalająca na instalację zamkniętego kodu (np. VS Code)
      unstable-pkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { unstable = unstable-pkgs; inherit inputs; };
        modules = [
          ./configuration.nix
          spicetify-nix.nixosModules.default
        ];
      };
    };
}

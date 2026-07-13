{
  description = "NixOS configuration — modular, two hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }: {

    # main: personal desktop (GNOME + PaperWM, Nvidia)
    nixosConfigurations.main = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/main/default.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.serkan = import ./hosts/main/home.nix;
          home-manager.backupFileExtension = "backup";
        }
      ];
    };

    # t230: work machine — home-manager standalone (add hardware.nix when ready)
    homeConfigurations."serkan@t230" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./hosts/t230/home.nix ];
    };

  };
}

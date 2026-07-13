{
  description = "NixOS configuration — modular, two hosts, two users each";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
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
          home-manager.users.sk  = import ./hosts/main/users/sk/home.nix;
          home-manager.users.dev = import ./hosts/main/users/dev/home.nix;
          home-manager.backupFileExtension = "backup";
        }
      ];
    };

    # t230: second machine (GNOME + PaperWM — add hardware.nix before deploying)
    nixosConfigurations.t230 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/t230/default.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.sk  = import ./hosts/t230/users/sk/home.nix;
          home-manager.users.dev = import ./hosts/t230/users/dev/home.nix;
          home-manager.backupFileExtension = "backup";
        }
      ];
    };

  };
}

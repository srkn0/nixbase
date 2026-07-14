{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sk-ssh-keys = {
      url = "https://github.com/srkn0.keys";
      flake = false;
    };
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, home-manager, sk-ssh-keys, disko, lanzaboote, ... }: {

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

    # x230: second machine (GNOME + PaperWM — add hardware.nix before deploying)
    nixosConfigurations.x230 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit sk-ssh-keys; };
      modules = [
        ./hosts/x230/default.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.sk  = import ./hosts/x230/users/sk/home.nix;
          home-manager.users.dev = import ./hosts/x230/users/dev/home.nix;
          home-manager.backupFileExtension = "backup";
        }
      ];
    };


    # xps17: laptop (GNOME + PaperWM, Nvidia GTX 1650Ti), single user
    nixosConfigurations.xps17 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit sk-ssh-keys; };
      modules = [
        ./hosts/xps17/default.nix
        ./hosts/xps17/disko.nix
        disko.nixosModules.disko
        lanzaboote.nixosModules.lanzaboote
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.sk = import ./hosts/xps17/users/sk/home.nix;
          home-manager.backupFileExtension = "backup";
        }
      ];
    };


    # vm-test: throwaway QEMU/KVM test VM — mirrors x230, VM hardware.nix
    nixosConfigurations.vm-test = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/vm-test/default.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.sk  = import ./hosts/x230/users/sk/home.nix;
          home-manager.users.dev = import ./hosts/x230/users/dev/home.nix;
          home-manager.backupFileExtension = "backup";
        }
      ];
    };

  };
}

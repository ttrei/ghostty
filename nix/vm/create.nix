{
  system,
  nixpkgs,
  home-manager,
  overlay,
  module,
  common ? ./common.nix,
  uid ? 1000,
  gid ? 1000,
}: let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [
      overlay
    ];
  };
in
  nixpkgs.lib.nixosSystem {
    system = builtins.replaceStrings ["darwin"] ["linux"] system;
    modules = [
      {
        virtualisation.vmVariant = {
          virtualisation.host.pkgs = pkgs;
        };

        nixpkgs.overlays = [
          overlay
        ];

        users.groups.ghostty = {
          gid = gid;
        };

        users.users.ghostty = {
          uid = uid;
        };

        system.stateVersion = nixpkgs.lib.trivial.release;

        home-manager.users.ghostty =
          { pkgs, ... }:
          {
            home.stateVersion = nixpkgs.lib.trivial.release;
            home.packages = with pkgs; [
              atuin
              ghostty
            ];
            programs.bash.enable = true;
            programs.atuin = {
              enable = true;
              enableBashIntegration = true;
            };
          };

      }
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
      common
      module
    ];
  }

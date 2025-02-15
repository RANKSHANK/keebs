{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zmk-nix }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
  in {
    packages = forAllSystems (system: rec {
      default = firmware;

      firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "firmware";

        src = nixpkgs.lib.sourceFilesBySuffices self [ ".conf" ".keymap" ".dtsi" ".yml" ".shield" ".overlay" ".defconfig" ];

        board = "nice_nano_v2";
        shield = "dactyl_manuform_5x6_%PART%";

        zephyrDepsHash = "sha256-qR3b0ooc1eXZ7r4OKGqFAqb2yH8novXFVRlkyE166dc=";

        meta = {
          description = "ZMK firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}

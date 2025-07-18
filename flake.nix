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
    lib = nixpkgs.lib;
    inherit (lib) flatten;
  in {
    packages = forAllSystems (system: let
        zmk = zmk-nix.legacyPackages.${system};

        meta = {
          description = "ZMK firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };

        zephyrDepsHash =
            "sha256-wHnW1cpwmkCePq3n0SarpfdJTg+fJqH+idLePD2766A=";
            # lib.fakeHash;

        src = nixpkgs.lib.sourceFilesBySuffices self [ ".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi" ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig" ];

    in rec {

      dactyl-5x6-dongle = zmk.buildKeyboard {
        inherit meta src zephyrDepsHash;
        board = "nice_nano_v2";
        shield = "dactyl_manuform_5x6_dongle dongle_display";
      };

      dactyl-5x6-peripherals = zmk.buildSplitKeyboard {
        inherit meta src zephyrDepsHash;
        name = "dactyl-5x6-peripherals";
        board = "nice_nano_v2";
        shield = "dactyl_manuform_5x6_%PART%";
      };
      inherit (zmk-nix.packages.${system}) update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}

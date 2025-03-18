{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  description = "Citrix Client";
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        systems = lib.systems.flakeExposed;
        lib = nixpkgs.lib;
        eachSystem = lib.genAttrs systems;
      in
      {
        legacyPackages = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
        packages.wfica =
          let
            pkgs = self.legacyPackages.${system};
          in
          pkgs.writeShellApplication {
            name = "wfica";
            checkPhase = ":";
            runtimeInputs = [
              pkgs.xorg.xauth
              pkgs.xdotool
            ];
            text = builtins.readFile (
              pkgs.substituteAll {
                src = ./jailed-wfica;
                citrix = pkgs.citrix_workspace;
              }
            );
          };
        defaultPackage = self.packages.${system}.wfica;
      }
    );
}

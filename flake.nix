{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };
  description = "Citrix Client";
  outputs = { self, nixpkgs }:
    let
      systems = lib.systems.flakeExposed;
      lib = nixpkgs.lib;
      eachSystem = lib.genAttrs systems;
    in {
      legacyPackages = eachSystem (system:
        import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        });
      packages.x86_64-linux.default =
        let pkgs = self.legacyPackages.x86_64-linux;
        in pkgs.writeShellApplication {
          name = "wfica";
          checkPhase = ":";
          runtimeInputs = [ pkgs.xorg.xauth ];
          text = builtins.readFile (pkgs.substituteAll {
            src = ./jailed-wfica;
            citrix = pkgs.citrix_workspace_22_05_0;
          });
        };
    };
}

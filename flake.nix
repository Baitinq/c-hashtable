{
  description = "Renfe flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-darwin" "aarch64-darwin" "x86_64-linux"];
    createDevShell = system: let
      pkgs = import nixpkgs {
        system = "${system}";
        config.allowUnfree = true;
      };
    in
      pkgs.mkShell {
        buildInputs = with pkgs; [
            zig
            gcc
            gnumake
            valgrind
            gdb
        ];
      };
  in {
    devShell = nixpkgs.lib.genAttrs systems createDevShell;
  };
}

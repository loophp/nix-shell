{
  description = "PHP/Composer";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = "github:numtide/flake-utils";
    phps.url = "github:fossar/nix-phps";
  };

  outputs = { self, flake-utils, nixpkgs, phps }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
      in {
        devShells = {
          default = import ./resources/dev/php {pkgs = pkgs; phps = phps.packages.${system};};
          php56 = import ./resources/dev/php56 {pkgs = pkgs; phps = phps.packages.${system};};
          php70 = import ./resources/dev/php70 {pkgs = pkgs; phps = phps.packages.${system};};
          php71 = import ./resources/dev/php71 {pkgs = pkgs; phps = phps.packages.${system};};
          php72 = import ./resources/dev/php72 {pkgs = pkgs; phps = phps.packages.${system};};
          php73 = import ./resources/dev/php73 {pkgs = pkgs; phps = phps.packages.${system};};
          php74 = import ./resources/dev/php74 {pkgs = pkgs; phps = phps.packages.${system};};
          php74-nodebug = import ./resources/dev/php74-nodebug {pkgs = pkgs; phps = phps.packages.${system};};
          php80 = import ./resources/dev/php80 {pkgs = pkgs; phps = phps.packages.${system};};
          php80-nodebug = import ./resources/dev/php80-nodebug {pkgs = pkgs; phps = phps.packages.${system};};
          php81-nodebug = import ./resources/dev/php81-nodebug {pkgs = pkgs; phps = phps.packages.${system};};
        };
      }
    );
}

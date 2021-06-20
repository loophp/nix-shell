{ pkgs ? (import <nixpkgs> {}), ... }:
(import ../common.nix) { inherit pkgs; phpPkg = pkgs.php80;}

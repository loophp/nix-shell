nixpkgs:
system:

let
  pkgs = import nixpkgs {
    inherit system;
  };
in
  pkgs
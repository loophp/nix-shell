nix-phps:
system:

let
  # TODO: Is it the proper way to do that?
  nixphps = nix-phps.packages.${system};
in
  nixphps
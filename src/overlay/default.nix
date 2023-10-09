inputs:

final:
prev:

let
  phps = import ./phps.nix inputs final prev;
  api = import ./api.nix inputs final prev;
in
phps // api

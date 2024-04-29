inputs:

final: prev:

let
  buildPhpFromComposer = prev.callPackage ../build-support/build-php-from-composer.nix { };
in
{
  api = {
    inherit buildPhpFromComposer;
  };
}

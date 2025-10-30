{ withSystem, ... }:
{
  flake = {
    overlays.default =
      _final: prev: withSystem prev.stdenv.hostPlatform.system ({ config, ... }: config.packages);
  };
}

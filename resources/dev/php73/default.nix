{
    pkgs,
    phps
}:

(import ../common.nix) {
    pkgs = pkgs;
    phps = phps;
    version = "php73";
    phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
}

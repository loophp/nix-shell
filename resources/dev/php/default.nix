{
    pkgs,
    phps
}:

(import ../common.nix) {
    pkgs = pkgs;
    phps = phps;
    version = "php";
    phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
}

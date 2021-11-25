{
    pkgs,
    phps
}:

(import ../common.nix) {
    pkgs = pkgs;
    phps = phps;
    version = "php81";
    phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [all.xdebug all.pcov]) (default all);
}

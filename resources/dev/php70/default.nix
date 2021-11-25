{
    pkgs,
    phps
}:

(import ../common.nix) {
    pkgs = pkgs;
    phps = phps;
    version = "php70";
}

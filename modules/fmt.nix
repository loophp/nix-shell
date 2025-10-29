{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        deadnix.enable = true;
        jsonfmt.enable = true;
        nixfmt.enable = true;
        prettier.enable = true;
        shfmt.enable = true;
        statix.enable = true;
        yamlfmt.enable = true;
      };
      settings = {
        on-unmatched = "fatal";
        global.excludes = [
          "*.envrc"
          ".github/CODEOWNERS"
          "docs/readme.gif"
          ".editorconfig"
          ".gitattributes"
          ".prettierrc"
          "*.crt"
          "*.directory"
          "*.face"
          "*.fish"
          "*.png"
          "*.toml"
          "*.svg"
          "*.xml"
          ".auto-changelog"
          ".user.ini"
          "*/.gitignore"
          "LICENSE"
        ];
      };
    };
  };
}

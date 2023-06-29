{ self
, lib
, ...
}:
let
  makePhp = pkgs:
    { php
    , extensions ? [ ]
    , withExtensions ? [ ]
    , withoutExtensions ? [ ]
    , extraConfig ? ""
    , extraConfigFile ? "${builtins.getEnv "PWD"}/.user.ini"
    , flags ? { }
    }:
    let
      # Normalize the php parameter(string or drv) into a derivation.
      phpDrv = if builtins.isString php then pkgs."${php}" else php;
    in
    ((phpDrv.override flags).buildEnv {
      extraConfig =
        extraConfig
        + "\n"
        + (
          if builtins.pathExists "${extraConfigFile}"
          then builtins.readFile "${extraConfigFile}"
          else ""
        );

      extensions = extensions@{ all, enabled, ... }:
        let
          buildExtensions =
            { all
            , enabled
            , withExtensions
            , withoutExtensions
            , composerExtensions ? [ ]
            }:
            let
              filterStringExtensions = extList:
                builtins.filter
                  (ext: (builtins.isString ext) && (lib.warnIf (!(all ? "${ext}")) "The ${ext} extension does not exist, ignoring." (all ? "${ext}")))
                  extList;

              filterDrvExtensions = extList:
                builtins.filter
                  (ext: (!builtins.isString ext) && (all ? el))
                  extList;

              # Filter only extensions provided as string
              userExtensionAsStringToAdd = filterStringExtensions (withExtensions ++ composerExtensions);
              userExtensionsAsStringToRemove = filterStringExtensions (withoutExtensions);

              # Display a warning when trying to build an extension that is already enabled or does not build
              e0 = builtins.map
                (ext: lib.warnIf ((builtins.tryEval all."${ext}".outPath).success == false) "The ${ext} extension is enabled in PHP ${phpDrv.version} but failed to instantiate, ignoring." ext)
                userExtensionAsStringToAdd;

              # Remove extensions that does not build
              e1 = builtins.filter
                (ext: (builtins.tryEval all."${ext}".outPath).success)
                e0;

              # Consolidate the list of extensions as derivations
              e2 = enabled ++ (builtins.map (ext: all."${ext}") e1) ++ (filterDrvExtensions withExtensions);

              # Remove unwanted extensions provided as strings
              e3 = builtins.filter
                (ext:
                  !((builtins.elem (ext.pname) (builtins.map (e: "php-${e}") userExtensionsAsStringToRemove)) ||
                    (builtins.elem (ext.pname) userExtensionsAsStringToRemove))
                )
                e2;

              # Remove unwanted extensions provided as derivations
              e4 = builtins.filter
                (ext: !builtins.elem ext (filterDrvExtensions withoutExtensions))
                e3;
            in
            e4;
        in
        (buildExtensions {
          inherit (extensions) all enabled;
          inherit withExtensions withoutExtensions;
          composerExtensions = self.composer.getExtensionFromSection "require" ++ self.composer.getExtensionFromSection "require-dev";
        });
    });
in
{
  flake.api = {
    inherit makePhp;
  };
}

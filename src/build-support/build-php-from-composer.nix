{ lib
, php
, pkgs
}@inputs:

let
  getExtensionsFromSection =
    { composerJson
    , section
    , default ? { }
    } @ args:
    let
      readJsonSectionFromFile = file: section: default:
        let
          filecontent =
            if builtins.pathExists composerJson
            then builtins.fromJSON (builtins.readFile composerJson)
            else { };
        in
          filecontent.${section} or default;

      # Get "require" section to extract extensions later
      require = readJsonSectionFromFile args.composerJson args.section args.default;
      # Copy keys into values
      composerRequiresKeys = map (p: lib.attrsets.mapAttrs' (k: v: lib.nameValuePair k k) p) [ require ];
      # Convert sets into lists
      composerRequiresMap = map (package: (map (key: builtins.getAttr key package) (builtins.attrNames package))) composerRequiresKeys;
    in
    # Convert the set into a list, filter out values not starting with "ext-", get rid of the first 4 characters from the name
    map (x: builtins.substring 4 (builtins.stringLength x) x) (builtins.filter (x: (builtins.substring 0 4 x) == "ext-") (lib.flatten composerRequiresMap));
in
{ src
, php ? inputs.php
, extensions ? [ ]
, withExtensions ? [ ]
, withoutExtensions ? [ ]
, extraConfig ? null
, flags ? { }
}:
let
  # Normalize the php parameter(string or drv) into a derivation.
  phpDrv = if builtins.isString php then pkgs."${php}" else php;
in
((phpDrv.override flags).buildEnv {
  extraConfig = lib.concatStrings [
    (lib.optionalString (extraConfig != null) extraConfig)
    (lib.optionalString (builtins.pathExists "${src}/.user.ini") (builtins.readFile "${src}/.user.ini"))
    (lib.optionalString (builtins.pathExists "${builtins.getEnv "PWD"}/.user.ini") (builtins.readFile "${builtins.getEnv "PWD"}/.user.ini"))
  ];

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
              (ext: (builtins.isString ext) && (lib.warnIf (!(all ? "${ext}")) "The ${ext} extension does not exist or is enabled by default in PHP ${phpDrv.version}, ignoring." (all ? "${ext}")))
              extList;

          filterDrvExtensions = builtins.filter lib.isDerivation;

          # Filter only extensions provided as string
          userExtensionAsStringToAdd = filterStringExtensions (withExtensions ++ composerExtensions);
          userExtensionsAsStringToRemove = filterStringExtensions (withoutExtensions);

          # Display a warning when trying to build an extension that is already enabled or does not build
          e0 = builtins.map
            (ext: lib.warnIf ((builtins.tryEval all."${ext}".outPath).success == false) "The ${ext} extension is enabled in PHP ${phpDrv.version} but failed to build, ignoring." ext)
            userExtensionAsStringToAdd;

          # Remove extensions that does not build
          e1 = builtins.filter
            (ext: (builtins.tryEval all."${ext}".outPath).success)
            e0;

          # Remove extensions provided as derivation to avoid duplicates
          # 1. Convert withExtensions to a list of strings
          # 2. Remove extensions that are in `enabled` and `e1` if they are in that list
          e2 = builtins.filter
            (ext: !builtins.elem (ext.pname) (builtins.map (e: e.pname) (filterDrvExtensions withExtensions)))
            (enabled ++ (builtins.map (ext: all."${ext}") e1));

          # Consolidate the list of extensions as derivations
          e3 = e2 ++ (filterDrvExtensions withExtensions);

          # Remove unwanted extensions provided as strings
          e4 = builtins.filter
            (ext:
              !((builtins.elem (ext.pname) (builtins.map (e: "php-${e}") userExtensionsAsStringToRemove)) ||
                (builtins.elem (ext.pname) userExtensionsAsStringToRemove))
            )
            e3;

          # Remove unwanted extensions provided as derivations
          e5 = builtins.filter
            (ext: !builtins.elem ext (filterDrvExtensions withoutExtensions))
            e4;
        in
        e5;
    in
    (buildExtensions {
      inherit (extensions) all enabled;
      inherit withExtensions withoutExtensions;
      composerExtensions =
        (getExtensionsFromSection { composerJson = "${src}/composer.json"; section = "require"; default = { }; }) ++
        (getExtensionsFromSection { composerJson = "${src}/composer.json"; section = "require-dev"; default = { }; }) ++
        (getExtensionsFromSection { composerJson = "${builtins.getEnv "PWD"}/composer.json"; section = "require"; default = { }; }) ++
        (getExtensionsFromSection { composerJson = "${builtins.getEnv "PWD"}/composer.json"; section = "require-dev"; default = { }; });
    });
})

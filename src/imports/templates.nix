{ ... }:

{
  flake = {
    templates = {
      basic = {
        path = ../../templates/basic;
        description = "A basic template for getting started with PHP development";
        welcomeText = builtins.readFile ../../templates/basic/README.md;
      };
    };
  };
}

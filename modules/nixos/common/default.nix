{ pkgs, ... }:
{
  imports = [
    ./myusers.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  # Turn off NIX_PATH warnings now that we're using flakes
  system.checks.verifyNixPath = false;

  nix = {
    enable = true;
    settings.trusted-users = [ "@admin" ];
    settings.experimental-features = "nix-command flakes";
    package = pkgs.lixPackageSets.stable.lix;
  };
}

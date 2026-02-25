{ pkgs, ... }:
{
  imports = [
    ./myusers.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  nix = {
    enable = true;
    settings.trusted-users = [ "@admin" ];
    settings.experimental-features = "nix-command flakes";
    package = pkgs.lixPackageSets.stable.lix;
  };
}

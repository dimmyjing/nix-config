{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
  ];

  # Defined by /modules/home/me.nix
  # And used all around in /modules/home/*
  me = {
    username = "jimmy";
    fullname = "Jimmy Ding";
    email = "git@jimmyding.com";
  };

  home.stateVersion = "25.11";
}

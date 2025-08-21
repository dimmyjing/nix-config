{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}:

let
  # Define the content of your file as a derivation
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit config pkgs; };
in
{
  config = {
    # It me
    users.users.jimmy = {
      name = "jimmy";
      home = "/Users/jimmy";
      isHidden = false;
      shell = pkgs.zsh;
    };

    homebrew = {
      enable = true;
      casks = pkgs.callPackage ./casks.nix { };
    };

    services.yabai = {
      enable = true;
      enableScriptingAddition = true;
      config = {
        focus_follows_mouse = "autofocus";
        mouse_follows_focus = "on";
      };
    };

    services.tailscale = {
      enable = true;
    };

    # Enable home-manager
    home-manager = {
      useGlobalPkgs = true;
      users.jimmy =
        {
          pkgs,
          config,
          lib,
          ...
        }:
        {
          home = {
            enableNixpkgsReleaseCheck = false;
            packages = pkgs.callPackage ./packages.nix { };
            file = lib.mkMerge [
              sharedFiles
              additionalFiles
            ];
            stateVersion = "23.11";
          }
          // import ../shared/home.nix { inherit config pkgs lib; };
          programs = { } // import ../shared/home-manager.nix { inherit config pkgs lib; };
        };
    };
  };
}

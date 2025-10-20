{
  config,
  pkgs,
  ...
}:

let
  # Define the content of your file as a derivation
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit config pkgs; };
  inherit (import ../../variables.nix) username;
in
{
  config = {
    # It me
    users.users."${username}" = {
      name = username;
      home = "/Users/${username}";
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
        focus_follows_mouse = "autoraise";
        mouse_follows_focus = "on";
      };
      extraConfig = '''';
    };

    services.tailscale = {
      enable = true;
    };

    # Enable home-manager
    home-manager = {
      useGlobalPkgs = true;
      users."${username}" =
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
            stateVersion = "25.11";
          }
          // import ../shared/home.nix { inherit config pkgs lib; };
          programs = { } // import ../shared/home-manager.nix { inherit config pkgs lib; };
        };
    };
  };
}

{ flake, pkgs, ... }:

# This is your nix-darwin configuration.
# For home configuration, see /modules/home/*
let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        enable = true;
        user = "jimmy";
        taps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
          "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
        };
        mutableTaps = false;
        autoMigrate = true;
      };
    }
    ./common
  ];

  config = {
    homebrew = {
      enable = true;
      casks = pkgs.callPackage ./casks.nix { };
    };

    services = {
      yabai = {
        enable = true;
        enableScriptingAddition = true;
        config = {
          focus_follows_mouse = "autoraise";
          mouse_follows_focus = "on";
        };
        extraConfig = "";
      };

      tailscale = {
        enable = true;
      };
    };

    # Use TouchID for `sudo` authentication
    security.pam.services.sudo_local = {
      touchIdAuth = true;
      reattach = true;
    };

    fonts.packages = with pkgs; [
      nerd-fonts.hack
    ];

    # Configure macOS system
    # More examples => https://github.com/ryan4yin/nix-darwin-kickstarter/blob/main/rich-demo/modules/system.nix
    system = {
      defaults = {
        LaunchServices = {
          # "Application Downloaded from Internet" popup will not display
          LSQuarantine = false;
        };

        NSGlobalDomain = {
          # Show all file extensions inside the Finder
          AppleShowAllExtensions = true;
          # Repeats the key as long as it is held down.
          ApplePressAndHoldEnabled = false;

          # 120, 90, 60, 30, 12, 6, 2
          KeyRepeat = 2;

          # 120, 94, 68, 35, 25, 15
          InitialKeyRepeat = 15;

          "com.apple.mouse.tapBehavior" = 1;
          "com.apple.sound.beep.volume" = 0.7;
          "com.apple.sound.beep.feedback" = 1;
        };

        dock = {
          autohide = true;
          show-recents = false;
          launchanim = true;
          mouse-over-hilite-stack = true;
          orientation = "bottom";
          tilesize = 64;
        };

        finder = {
          _FXShowPosixPathInTitle = true; # show full path in finder title
        };

        trackpad = {
          Clicking = true;
        };
      };

      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
    };
  };
}

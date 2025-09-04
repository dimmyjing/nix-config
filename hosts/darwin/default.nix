{ pkgs, ... }:

{
  imports = [
    ../../modules/darwin/home-manager.nix
  ];

  config = {
    # # Create datadir for PostgreSQL
    # system.activationScripts.preActivation = {
    #   enable = true;
    #   text = ''
    #     if [ ! -d "/var/lib/postgresql/" ]; then
    #       echo "creating PostgreSQL data directory..."
    #       sudo mkdir -m 750 -p /var/lib/postgresql/
    #       chown -R jimmy:staff /var/lib/postgresql/
    #     fi
    #   '';
    # };
    #
    # services.postgresql = {
    #   enable = true;
    #   dataDir = "/var/lib/postgresql";
    #   authentication = pkgs.lib.mkOverride 10 ''
    #     local all all trust
    #     host all all 127.0.0.1/32 trust
    #     host all all ::1/128 trust
    #   '';
    #   initdbArgs = [
    #     "--username=jimmy"
    #     "--pgdata=/var/lib/postgresql"
    #     "--auth=trust"
    #     "--no-locale"
    #     "--encoding=UTF8"
    #   ];
    #   extraPlugins = [ (pkgs.postgresql_16.pkgs.pgvector.override { postgresql = pkgs.postgresql_16; }) ];
    #   package = pkgs.postgresql_16;
    # };
    #
    # launchd.user.agents.postgresql.serviceConfig = {
    #   StandardErrorPath = "/tmp/postgres.error.log";
    #   StandardOutPath = "/tmp/postgres.log";
    # };

    # Setup user, packages, programs
    nix = {
      package = pkgs.nixVersions.latest;
      settings.trusted-users = [
        "@admin"
        "jimmy"
      ];
      settings.experimental-features = "nix-command flakes";
    };

    programs.zsh.enable = true;

    # Turn off NIX_PATH warnings now that we're using flakes
    system.checks.verifyNixPath = false;

    # Load configuration that is shared across systems
    environment.systemPackages = import ../../modules/shared/packages.nix { inherit pkgs; };

    security.pam.services.sudo_local.touchIdAuth = true;

    fonts.packages = with pkgs; [
      nerd-fonts.hack
    ];

    system = {
      primaryUser = "jimmy";

      stateVersion = 4;

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
          "com.apple.sound.beep.volume" = 0.0;
          "com.apple.sound.beep.feedback" = 0;
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
          _FXShowPosixPathInTitle = false;
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

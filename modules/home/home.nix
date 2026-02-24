{
  config,
  pkgs,
  lib,
  ...
}:

{
  home = {
    preferXdgDirectories = true;

    sessionVariables = {
      VI_MODE_SET_CURSOR = "true";
      XDG_CONFIG_HOME = config.xdg.configHome;
      XDG_DATA_HOME = config.xdg.dataHome;
      XDG_CACHE_HOME = config.xdg.cacheHome;
      PATH = "$HOME/go/bin:$HOME/.cargo/bin:$HOME/.bun/bin:$PATH";
      DOCKER_HOST = "unix://$(podman machine inspect --format '{{ .ConnectionInfo.PodmanSocket.Path }}' 2>/dev/null || true)";
      PYTHON_HISTORY = "${config.xdg.dataHome}/python/history";
      GOENV = "${config.xdg.configHome}/go/env";
      GOPATH = "${config.xdg.dataHome}/go";
      GOCACHE = "${config.xdg.cacheHome}/go-build";
      PKG_CONFIG_PATH = "${pkgs.icu78.dev}/lib/pkgconfig:${pkgs.openssl_oqs.dev}/lib/pkgconfig";
      POSTGRES_CONFIGURE_OPTIONS = "--with-uuid=e2fs --with-openssl --with-zlib --with-libraries=${pkgs.openssl_oqs.out}/lib --with-includes=${pkgs.openssl_oqs.dev}/include";
      POSTGRES_SKIP_INITDB = "true";
    };
  };

  # Garbage collect the Nix store
  nix.gc = {
    automatic = true;
    # Change how often the garbage collector runs (default: weekly)
    # frequency = "monthly";
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      update = "sudo sh -c \"cd /Users/${config.me.username}/Workspace/nix && git add . && nix run && yabai --load-sa\"";
      source_env = "export __HM_SESS_VARS_SOURCED= && source ~/.nix-profile/etc/profile.d/hm-session-vars.sh";
      src = "cd ~/Workspace";
      ls = "ls -G --color=auto";
      m = "mise";
      mr = "mise run";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "vi-mode"
        "extract"
        "safe-paste"
        "tmux"
      ];
    };
    plugins = [
      {
        name = "zsh-async";
        file = "async.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "mafredri";
          repo = "zsh-async";
          rev = "v1.8.6";
          sha256 = "sha256-Js/9vGGAEqcPmQSsumzLfkfwljaFWHJ9sMWOgWDi0NI=";
        };
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ../../files;
        file = "p10k.zsh";
      }
    ];
    syntaxHighlighting = {
      enable = true;
    };
    initContent = ''
      eval "$(mise activate zsh)"
      # TODO: switch to managing pitchfork within nix
      eval "$(pitchfork activate zsh)"
    '';
    dotDir = "${config.xdg.configHome}/zsh";
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      # vim-tmux-navigator
      sensible
      # yank
      {
        plugin = power-theme;
        extraConfig = ''
          set -g @tmux_power_theme '#8FAEF9'
          set -g default-terminal "tmux-256color"
          set -ag terminal-overrides ",$TERM:RGB"
        '';
      }
    ];
    baseIndex = 1;
    mouse = true;
    historyLimit = 50000;
    keyMode = "vi";
    shell = "$SHELL";
    extraConfig = ''
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R
      set -g default-command $SHELL
    '';
  };

  # programs.zellij = {
  #   enable = true;
  #   enableZshIntegration = true;
  #   attachExistingSession = true;
  #   exitShellOnExit = true;
  # };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = config.me.fullname;
        email = config.me.email;
      };
      pull.rebase = true;
      rebase.autoStash = true;
      rebase.autosquash = true;
      rerere.enabled = true;
      init.defaultBranch = "main";
    };
    lfs = {
      enable = true;
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config.global = {
      # Make direnv messages less verbose
      hide_env_diff = true;
    };
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    # settings = {
    # keymap_mode = "vim";
    # enter_accept = true;
    # };
  };

  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      font-family = "Hack Nerd Font Mono";
      font-size = 20;
      theme = "Catppuccin Mocha";
      keybind = [
        "super+t=text:\\x02c"
        "super+w=text:\\x02&"
        "super+d=text:\\x02%"
        "super+shift+d=text:\\x02\""
        "super+digit_1=text:\\x021"
        "super+digit_2=text:\\x022"
        "super+digit_3=text:\\x023"
        "super+digit_4=text:\\x024"
        "super+digit_5=text:\\x025"
        "super+digit_6=text:\\x026"
        "super+digit_7=text:\\x027"
        "super+digit_8=text:\\x028"
        "super+digit_9=text:\\x029"
        "ctrl+h=text:\\x02h"
        "ctrl+j=text:\\x02j"
        "ctrl+k=text:\\x02k"
        "ctrl+l=text:\\x02l"
        "ctrl+tab=text:\\x02n"
        "ctrl+shift+tab=text:\\x02p"
      ];
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = config.me.fullname;
        email = config.me.email;
      };
      template-aliases = {
        "format_short_change_id(id)" = "id.shortest(4)";
        "format_short_commit_id(id)" = "id.shortest(4)";
        prompt = ''
          separate(" ",
            format_short_change_id_with_hidden_and_divergent_info(self),
            format_short_commit_id(commit_id),
            if(empty, label("empty", "(empty)"), ""),
            if(description == "", label("description placeholder", "(no description)"), ""),
            if(description.contains("megamerge"), label("mega", "(mega)"), ""),
            if(description.starts_with("wip"), label("wip", "(wip)"), ""),
            if(description.starts_with("todo"), label("todo", "(todo)"), ""),
            if(description.starts_with("vibe"), label("vibe", "(vibe)"), ""),
            if(description.starts_with("mega"), label("mega", "(mega)"), ""),
            if(conflict, label("conflict", "(conflict)"), "")
          )
        '';
      };
      revset-aliases = {
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
      };
      colors = {
        wip = "yellow";
        todo = "blue";
        vibe = "cyan";
        mega = "red";
      };
    };
  };

  programs.readline = {
    enable = true;
    extraConfig = ''
      set editing-mode vi
    '';
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

{
  zsh = {
    enable = true;
    shellAliases = {
      src = "cd ~/Workspace";
      ls = "ls -G --color=auto";
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
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./config;
        file = "p10k.zsh";
      }
    ];
    syntaxHighlighting = {
      enable = true;
    };
    initContent = ''
      export PATH="$HOME/go/bin:$PATH"
      export PATH="$HOME/.cargo/bin:$PATH"
      export DOCKER_HOST="unix://$HOME/.colima/docker.sock"
    '';
  };

  tmux = {
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

  git = {
    enable = true;
    userName = "Jimmy Ding";
    userEmail = "jimmyguding@gmail.com";
    lfs = {
      enable = true;
    };
    extraConfig = {
      pull.rebase = true;
      rebase.autoStash = true;
      rebase.autosquash = true;
      rerere.enabled = true;
      init.defaultBranch = "main";
    };
  };

  neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    # settings = {
    # keymap_mode = "vim";
    # enter_accept = true;
    # };
  };
}

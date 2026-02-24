{ lib, pkgs, ... }:
{
  home = {
    file = {
      "./.config/nvim" = {
        source = ../../files/nvim;
        recursive = true;
      };

      ".config/karabiner/karabiner.json" = lib.mkIf pkgs.stdenv.isDarwin {
        source = ../../files/karabiner.json;
      };
    };
  };
}

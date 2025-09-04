{ ... }:
{
  "./.config/nvim" = {
    source = ./config/nvim;
    recursive = true;
  };
  "./.inputrc" = {
    text = ''
      set editing-mode vi
    '';
  };
  "./.config/btop/themes/catppuccin.theme" = {
    source = ./config/btop.theme;
  };
  "./.config/ghostty/config" = {
    source = ./config/ghostty/config;
  };
}

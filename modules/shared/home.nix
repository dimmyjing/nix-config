{
  config,
  pkgs,
  lib,
  ...
}:

{
  sessionVariables = {
    VI_MODE_SET_CURSOR = "true";
  };
}

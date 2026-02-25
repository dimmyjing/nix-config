# User configuration module
{ config, lib, ... }:
{
  options = {
    me = {
      primaryUser = lib.mkOption {
        type = lib.types.str;
        description = "Your username as shown by `id -un`";
      };
    };
  };
  config = {
    system.primaryUser = config.me.primaryUser;
  };
}

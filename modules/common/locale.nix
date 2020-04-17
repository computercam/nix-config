{ config, lib, pkgs, options, ... }: {
  config = {
    environment.variables.LANG = "en_US.UTF-8";
    time.timeZone = "UTC";
  };
}

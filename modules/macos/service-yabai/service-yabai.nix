# https://github.com/koekeishiya/yabai
# https://github.com/koekeishiya/skhd
#
# Tiling window manager and hotkey daemon for macOS.
# Requires Homebrew (service-homebrew) to install yabai, skhd, and borders.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.cfg;

  # Homebrew installs to /opt/homebrew on Apple Silicon, /usr/local on Intel.
  homebrewPrefix = if pkgs.stdenv.hostPlatform.isAarch64 then "/opt/homebrew" else "/usr/local";
  skhd = "${homebrewPrefix}/bin/skhd";
  yabai = "${homebrewPrefix}/bin/yabai";

  # Derive config paths from the user's home directory.
  userHome = config.users.users."${cfg.user.name}".home;
  skhdrc = "${userHome}/.config/skhd/skhdrc";
  yabairc = "${userHome}/.config/yabai/yabairc";
  path = "${homebrewPrefix}/bin:/run/current-system/sw/bin:${config.environment.systemPath}";
in
{
  imports = [ ../service-homebrew/service-homebrew.nix ];

  config = {
    cfg.homebrew.enable = mkDefault true;
    cfg.homebrew.taps = [
      "koekeishiya/formulae"
      "FelixKratz/formulae"
    ];
    cfg.homebrew.brews = [
      "yabai"
      "skhd"
      "borders"
    ];

    security.accessibilityPrograms = [
      "${yabai}"
      "${skhd}"
    ];

    # Load the yabai scripting addition (SA) at boot via a root daemon.
    # The SA is required for yabai to control windows it doesn't own.
    launchd.daemons.yabai-sa = {
      script = ''
        if [ ! $(${yabai} --check-sa) ]; then
          ${yabai} --install-sa
        fi
        ${yabai} --load-sa
      '';
      serviceConfig.RunAtLoad = true;
      serviceConfig.KeepAlive.SuccessfulExit = false;
    };

    # Allow the primary user to reload the SA without a password.
    # NOTE: yabai --load-sa injects code into the WindowServer process,
    # which is effectively a privilege-escalation primitive. This is
    # required for yabai's window management features.
    environment.etc."sudoers.d/yabai" = {
      enable = true;
      mode = "0440";
      text = ''
        ${cfg.user.name} ALL = (root) NOPASSWD: ${yabai} --load-sa
      '';
    };

    launchd.user.agents.yabai = {
      serviceConfig.ProgramArguments = [
        "${yabai}"
        "-c"
        "${yabairc}"
      ];
      serviceConfig.KeepAlive = true;
      serviceConfig.ProcessType = "Interactive";
      serviceConfig.EnvironmentVariables = {
        PATH = "${path}";
      };
    };

    launchd.user.agents.skhd = {
      serviceConfig.ProgramArguments = [
        "${skhd}"
        "-c"
        "${skhdrc}"
      ];
      serviceConfig.KeepAlive = true;
      serviceConfig.ProcessType = "Interactive";
      serviceConfig.EnvironmentVariables = {
        PATH = "${path}";
      };
    };
  };
}
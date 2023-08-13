{ config, lib, pkgs, options, ... }: {
  cgf.os.name = "macos";

  nix.settings.allowed-users = [ "@staff" ];
  
  system.defaults = {
    NSGlobalDomain = {
      AppleMeasurementUnits = config.cfg.localization.measurement;
      AppleTemperatureUnit = config.cfg.localization.temperature;
      NSAutomaticWindowAnimationsEnabled = false;
      NSScrollAnimationEnabled = false;
      NSWindowResizeTime = 1.001;
      NSUseAnimatedFocusRing = false;
      _HIHideMenuBar = false;
      "com.apple.swipescrolldirection" = false;
    };

    alf = {
      stealthenabled = 1;
      loggingenabled = 1;
    };

    finder = { CreateDesktop = false; };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.0;
      expose-animation-duration = 0.0;
      minimize-to-application = true;
      mru-spaces = false;
      tilesize = 32;
      orientation = "left";
    };

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      QuitMenuItem = true;
      _FXShowPosixPathInTitle = true;
    };

    spaces.spans-displays = false;
  };

  system.keyboard = { enableKeyMapping = true; };
}

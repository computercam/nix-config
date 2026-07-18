# macOS system defaults.
#
# This module is intentionally empty — all macOS defaults are opinionated
# and should be set in your private config (e.g. hosts/<name>/modules/defaults.nix).
#
# See: https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults
#
# Example settings to copy to your private config:
#
# system.keyboard.enableKeyMapping = true;
# system.defaults.NSGlobalDomain = {
#   AppleMeasurementUnits = "Centimeters";  # or "Inches"
#   AppleTemperatureUnit = "Celsius";        # or "Fahrenheit"
#   NSAutomaticWindowAnimationsEnabled = false;
#   NSScrollAnimationEnabled = false;
#   NSWindowResizeTime = 1.001;
#   NSUseAnimatedFocusRing = false;
#   _HIHideMenuBar = false;
#   "com.apple.swipescrolldirection" = false;  # disable natural scrolling
# };
# system.defaults.alf = {
#   globalstate = 1;      # firewall on (1 = essential services, 2 = block all incoming)
#   stealthenabled = 1;   # drop unsolicited packets silently
#   loggingenabled = 1;
# };
# system.defaults.dock = {
#   autohide = true;
#   autohide-delay = 0.0;
#   autohide-time-modifier = 0.0;
#   expose-animation-duration = 0.0;
#   minimize-to-application = true;
#   mru-spaces = false;
#   tilesize = 32;
#   orientation = "left";
# };
# system.defaults.finder = {
#   CreateDesktop = true;
#   AppleShowAllExtensions = true;
#   FXEnableExtensionChangeWarning = false;
#   QuitMenuItem = true;
#   _FXShowPosixPathInTitle = true;
# };
# system.defaults.spaces.spans-displays = false;
{
  ...
}:
{
}
{
  config,
  lib,
  pkgs,
  options,
  ...
}:
{
  config = {
    environment.systemPackages = with pkgs; [
      # lutris
      # steam
      # steam-run-native
      # vulkan-tools
      protontricks
      winetricks
      wine-staging
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    services.pulseaudio.support32Bit = true;

    hardware = {
      enableRedistributableFirmware = true;
      graphics.enable = true;
      graphics.enable32Bit = true;
      steam-hardware.enable = true;
    };

    # # Increase ulimit for Lutris
    # systemd = {
    #   extraConfig = "DefaultLimitNOFILE=524288";
    #   user.extraConfig = "DefaultLimitNOFILE=524288";
    # };

    # security.pam.loginLimits = [{
    #   domain = "*";
    #   type = "soft";
    #   item = "nofile";
    #   value = "524288";
    # }];
  };
}

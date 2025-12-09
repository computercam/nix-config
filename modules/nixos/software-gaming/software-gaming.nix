{ config, lib, pkgs, options, ... }: {
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

    hardware = {
      ## 32 bit support for Lutris
      # enableRedistributableFirmware = true;
      # pulseaudio.support32Bit = true;

      # opengl = {
      #   enable = true;
      #   driSupport = true;
      #   driSupport32Bit = true;
      # };

      # Support for gaming peripherals
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

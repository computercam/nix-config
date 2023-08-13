{ config, lib, pkgs, options, ... }: {
  config = {
    environment.systemPackages = with pkgs; [
      lutris
      steam
      steam-run-native
      protontricks
      winetricks
      wine-staging
      vulkan-tools
    ];

    # 32 bit support for Lutris
    hardware = {
      enableRedistributableFirmware = true;
      pulseaudio.support32Bit = true;

      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };

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

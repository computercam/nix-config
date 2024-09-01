{ config, lib, pkgs, options, ... }: {
  config = {
    home-manager.users."${config.cfg.user.name}" = {
      home.packages = with pkgs; [
          python3Full
          python3Packages.pip
          nodejs
          nodePackages.npm
          cargo
          rustc
          # vscode
          yarn
        ];
    };

    networking.firewall.allowedTCPPorts = [ 
      1234
      3000
      3001
    ];
  };
}

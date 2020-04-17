{ config, pkgs, lib, ... }: 
with pkgs.stdenv; with lib; 
{ 
  config.environment = mkMerge 
  [
    (mkIf isLinux {
      systemPackages = with pkgs; [
        dateutils
        killall
        lshw
        lsof
        protonvpn-cli
      ];
    })

    {
      systemPackages = with pkgs; [ 
        # generic
        coreutils-full
        parallel
        stow
        nixfmt
        nix-prefetch-git
        lazygit
        # files
        findutils
        lsof
        rsync
        # multimedia
        ffmpeg-full
        imagemagick
        imlib2
        librsvg
        optipng
        # downloading 
        curl
        lftp
        wget
        youtube-dl
        # archives
        p7zip
        par2cmdline
        unrar
        unzip
        zip
        # networking
        iftop
        inetutils
        nmap
        speedtest-cli
        tcpdump
      ];
    }
  ];
}

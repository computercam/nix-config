{ config, lib, pkgs, options, ... }:

with lib;

let
  AllowGroups = "sshusers";
  ClientAliveCountMax = "2";
  ClientAliveInterval = "15";
  EnableClientForwardX11 = false;
  EnableDaemonForwardX11 = false;
  LoginGraceTime = "1m";
  PasswordAuthentication = true;
  Ports = [ 8282 ];
  PubkeyAuthentication = "yes";
  TCPKeepAlive = "yes";
  AllowSFTP = true;
  Gnupg = true;
  GoogleAuthenticator = true;
  Packages = with pkgs; [ sshfs google-authenticator ];
in {
  config = {
    environment.systemPackages = Packages;

    programs.gnupg = {
      agent = {
        enable = Gnupg;
        enableSSHSupport = Gnupg;
        enableExtraSocket = Gnupg;
      };
      dirmngr.enable = Gnupg;
    };

    programs.ssh = {
      forwardX11 = EnableClientForwardX11;
      setXAuthLocation = EnableClientForwardX11;
    };

    services.openssh = {
      enable = true;
      allowSFTP = AllowSFTP;
      forwardX11 = EnableDaemonForwardX11;
      passwordAuthentication = PasswordAuthentication;
      permitRootLogin = "no";
      ports = Ports;
      startWhenNeeded = true;

      extraConfig = ''
        AllowGroups ${AllowGroups}
        ClientAliveCountMax ${ClientAliveCountMax}
        ClientAliveInterval ${ClientAliveInterval}
        LoginGraceTime ${LoginGraceTime}
        PermitEmptyPasswords no
        PubkeyAuthentication ${PubkeyAuthentication}
        TCPKeepAlive ${TCPKeepAlive}
      '';
    };

    # PAM 2 FACTOR AUTH
    # Users with enabled Google Authenticator (created ~/.google_authenticator) will be required to provide Google Authenticator token to log in via sshd.
    # https://wiki.archlinux.org/index.php/Google_Authenticator
    security.pam.services.sshd.googleAuthenticator.enable = GoogleAuthenticator;
  };
}

{
  config,
  lib,
  pkgs,
  options,
  ...
}:
with pkgs.stdenv;
with lib;
{
  config = {
    users.groups.sshusers = { };
    users.users."${config.cfg.user.name}".extraGroups = [ "sshusers" ];

    services.openssh = {
      settings = {
        PasswordAuthentication = config.cfg.ssh.passwordAuthentication;
        PermitRootLogin = "no";
        X11Forwarding = false;
        LogLevel = "VERBOSE";
        KbdInteractiveAuthentication = config.cfg.ssh.kbdInteractiveAuthentication;
      };
      allowSFTP = true;
      enable = true;
      openFirewall = true;
      ports = [ config.cfg.ssh.port ];
      startWhenNeeded = true;

      # TODO: consider remove uneeded options here
      # TODO: consider making these values configurable

      extraConfig = ''
        AllowGroups sshusers
        ClientAliveCountMax 2
        ClientAliveInterval 15
        LoginGraceTime 1m
        PermitEmptyPasswords no
        PrintLastLog yes
        PubkeyAuthentication yes
        TCPKeepAlive yes
      '';
    };

    # Auto-configure fail2ban sshd jail when fail2ban is enabled.
    # The fail2ban module (service-fail2ban) provides the framework; this module
    # declares the sshd-specific jail. services.fail2ban.enable is a nixpkgs
    # built-in option that's always available (defaults to false), so there's
    # no hard dependency on the service-fail2ban module being imported.
    services.fail2ban.jails.sshd = mkIf config.services.fail2ban.enable {
      enabled = true;
      settings = {
        port = toString config.cfg.ssh.port;
      };
    };

    # # PAM 2 FACTOR AUTH
    # # Users with enabled Google Authenticator (created ~/.google_authenticator) will be required to provide Google Authenticator token to log in via sshd.
    # # https://wiki.archlinux.org/index.php/Google_Authenticator
    # security.pam.services.sshd.googleAuthenticator.enable = true;
  };
}

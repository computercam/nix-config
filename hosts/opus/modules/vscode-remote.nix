{ config, pkgs, ... }: {
  imports = [ (fetchTarball { 
    url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
    sha256 = "sha256:1rq8mrlmbzpcbv9ys0x88alw30ks70jlmvnfr2j8v830yy5wvw7h";
  }) ];
  services.vscode-server.enable = true;
  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-16.20.2"
  ];
}
# https://hackmd.io/mLxjbE1jQwydlGXBA3UnkA?view#Solution
# make sure to run this as your user after importing this
# systemctl --user enable auto-fix-vscode-server.service

# Example zshInitExtraConfig.nix
#
# This file defines your zsh configuration as a Nix attribute set.
# Copy this to your private config and customize it.
# Set cfg.home.zshInitExtraConfigFile to the path of your config file.
#
# {
#   config,
#   lib,
#   pkgs,
#   ...
# }:
#
# with pkgs;
# with pkgs.stdenv;
# with lib;
#
# {
#   ohMyZsh = {
#     enable = true;
#     plugins = [ "git" ];
#   };
#
#   variables = {
#     # TERM = "xterm-256color";
#     # PYENV_ROOT = "$HOME/.pyenv";
#     # NVM_DIR = "$HOME/.nvm";
#     # LESS = "--RAW-CONTROL-CHARS";
#     # LESS_TERMCAP_mb = "$(tput bold; tput setaf 2)";
#     # LESS_TERMCAP_md = "$(tput bold; tput setaf 6)";
#     # LESS_TERMCAP_me = "$(tput sgr0)";
#   };
#
#   aliases = {
#     # cat = "${pkgs.bat}/bin/bat";
#     # ls = "${pkgs.eza}/bin/eza --icons -h";
#     # vi = "${pkgs.neovim}/bin/nvim";
#     # vim = "${pkgs.neovim}/bin/nvim";
#     # cd = "z";
#   };
#
#   setOpts = [
#     # "AUTOCD"
#     # "AUTOPUSHD"
#     # "COMPLETE_ALIASES"
#     # "CORRECT"
#     # "EXTENDED_HISTORY"
#     # "EXTENDEDGLOB"
#     # "HIST_EXPIRE_DUPS_FIRST"
#     # "HIST_FCNTL_LOCK"
#     # "HIST_IGNORE_DUPS"
#     # "HIST_IGNORE_SPACE"
#     # "NOBEEP"
#     # "NOCASEGLOB"
#     # "NOCHECKJOBS"
#     # "NUMERIC_GLOB_SORT"
#     # "PROMPT_SUBST"
#     # "RCEXPANDPARAM"
#     # "SHARE_HISTORY"
#   ];
#
#   completions = {
#     # accept-exact = "'*(N)'";
#     # cache-path = "~/.zsh/cache";
#     # list-colors = ''"\$\{(s.:.)LS_COLORS\}"'';
#     # matcher-list = "'m:{a-zA-Z}={A-Za-z}'";
#     # rehash = "true";
#     # use-cache = "on";
#   };
#
#   keybindings = {
#     # delete-char = "\\e[3~";
#     # forward-char = "^[[c";
#     # backward-char = "^[[d";
#     # forward-word = "^[[1;5C";
#     # backward-word = "^[[1;5D";
#     # backward-kill-word = "^[[1;7D";
#     # kill-word = "^[[1;7C";
#     # history-substring-search-down = "^[[B";
#     # history-substring-search-up = "^[[A";
#     # beginning-of-line = "^[[H";
#     # end-of-line = "^[[F";
#   };
#
#   paths = [
#     # "$HOME/scripts"
#     # "$HOME/.cargo/bin"
#     # "$HOME/.local/bin"
#   ];
#
#   fpaths = with pkgs; [
#     # "${zsh-completions}/share/zsh/site-functions"
#     # "${zsh-fast-syntax-highlighting}/share/zsh/site-functions"
#   ];
#
#   sources = with pkgs; [
#     # "${zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
#     # "${zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
#     # "${zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh"
#   ];
#
#   extras = [
#     # ''eval "$(${pkgs.starship}/bin/starship init zsh)"''
#     # ''eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"''
#   ];
# }
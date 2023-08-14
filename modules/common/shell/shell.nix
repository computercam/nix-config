{ config, lib, pkgs, options, ... }:
with pkgs.stdenv;
with lib;
let
  shell = config.cfg.shell;
in {
  imports = [ ./options.nix ];

  home-manager.users."${config.cfg.user.name}" = {
    programs.zsh = {
      enable = true;

      initExtra = ''
        function pathIf () {
          [ -e "$1" ] && export PATH="$PATH:$1"
        }

        function sourceIf() {
          [ -e "$1" ] && source $1
        }

        function fpathIf() {
          [ -e "$1" ] && fpath=($1 $fpath)
        }

        ${optionalString (shell.fpaths != []) ''
          ### FUNCTION PATHS

          fpathIf ${concatStringsSep "\nfpathIf " shell.fpaths}
        ''}

        ${optionalString (shell.sources != []) ''
          ### SOURCES

          sourceIf ${concatStringsSep "\nsourceIf " shell.sources}
        ''}

        ${optionalString (shell.paths != []) ''
          ### PATHS

          pathIf ${concatStringsSep "\npathIf " shell.paths}
        ''}  

        ${optionalString (shell.ohMyZsh.enable == true) ''
          ### OH-MY-ZSH
          
          export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
          
          ${optionalString (shell.ohMyZsh.plugins != []) ''
            plugins=(${concatStringsSep " " shell.ohMyZsh.plugins})
          ''}

          source $ZSH/oh-my-zsh.sh
        ''}
        
        ${optionalString (shell.variables != {}) ''
          ### VARIABLES

          ${concatStringsSep "\n" 
              (lib.attrsets.mapAttrsToList 
                (name: value: ''${name}="${value}";'') 
                shell.variables)}
        ''}

        ${optionalString (shell.aliases != {}) ''
          ### ALIASES

          ${concatStringsSep "\n" 
              (lib.attrsets.mapAttrsToList 
                (name: value: ''alias ${name}="${value}";'') 
                shell.aliases)}
        ''}

        ${optionalString (shell.setOpts != []) ''
          ### OPTIONS

          setopt ${concatStringsSep "\nsetopt " shell.setOpts}
        ''}

        ${optionalString (shell.completions != {}) ''
          ### COMPLETIONS

          ${concatStringsSep "\n" 
              (lib.attrsets.mapAttrsToList 
                (name: value: ''zstyle ':completion:*' ${name} ${value}'') 
                shell.completions)}
        ''}

        ${optionalString (shell.keybindings != {}) ''
          ### KEYBINDINGS
          ## http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets
          ## showkey -a       # get keyboard keycodes
          ## zle -la | less   # get all possible commands
          ## bindkey          # get all currently bounded commands

          bindkey -e

          ${concatStringsSep "\n" 
              (lib.attrsets.mapAttrsToList 
                (name: value: ''bindkey '${value}' ${name}'') 
                shell.keybindings)}
        ''}

        ${optionalString (shell.extras != []) ''
          ### EXTRAS

          ${concatStringsSep "\n" shell.extras}
        ''}       
      '';
    };
  };
}


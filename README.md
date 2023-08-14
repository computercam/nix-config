# NixOS and Nix-Darwin configurations

## Configuration

### Flake

This configuration uses flakes with multiple host configurations. 

- Host systems are declared in this file with a hostname that cooresponds to directories in the `./hosts` directory.
  - Host configurations should be defined at `./hosts/[hostname]/configuration.nix` and imported here.
- Global system configurations are imported to this file.
  - Global configurations should be defined at `./modules/global` and imported here.

### Modules

Configurations defined within the `./modules` directory define a components of functionality. 

- Global configurations are stored in the `global` directory.
- Shared modules are defined in the `common` directory.
- Nixos specific modules are defined in the `nixos` sub-directory.
- Darwin specific modules are defined in the `darwin` sub-directory.

Here are some examples of modules:

- `shell`: zsh configs and shell related packages to make those configurations work.
- `nvidia`: configures and installs the drivers for nvidia gpus on nixos.

Inividual modules are meant to be imported into Host configurations.

### Hosts

Host specific configurations are stored in the `./hosts/` directory.

- Configurations are in a subdirectory with a system specific name.
- Subdirectory must contain a `configuration.nix` file.
- Hardware and workstations specific configurations should be defined within the `[hostname]` directory instead of in `modules`.

## Installing

### Nixos

If you're running the NixOS live install medium, use the live medium's built in installer. 

If NixOS is already installed, you don't need to do anything else.

### OSX

If you're using OSX, you can use the scripts in `scripts/darwin/` to get you started. 

I would recommend doing following:

1. `scripts/darwin/nix-drive.sh`
    - This script will create a separate mount point for nix at `/nix`
2. `scripts/darwin/nix-install.sh`
    - This script will install nix if the previous script created `/nix`
3. `scripts/darwin/nix-darwin-install.sh`
    - This script will install nix-darwin using nix.

## Initializing your configuraiton

For the initial configuration of your system you need to run the following command from the project directory.

```
init.sh [hostname]
```

This command will set your hostname to `[hostname]` and link `./flake.nix` to your global configuration directory. _This makes it so that running `nixos-rebuild` or `darwin-rebuild` uses your `flake.nix`._

## Testing Nix Expressions in the CLI

You can evaluate nix expressions using `nix-instantiate` .

Here's an example:

```bash
nix-instantiate --eval --expr 'with import <nixpkgs> {}; (NIX EXPRESSION HERE. we can also use `lib` and `builtins` as well.)'
```

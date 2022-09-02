# NixOS and Nix-Darwin configurations

## Configuration

### Global

Global configurations are stored in the `./config/global/global.nix` file.
These define configuration that apply to every system, regardless of its purpose.

### Modules

Configurations defined within the `./config/modules` directory define a components of functionality. 

- Shared modules are defined in the `common` directory.
- Nixos specific modules are defined in the `nixos` sub-directory.
- Darwin specific modules are defined in the `darwin` sub-directory.

Here are some examples of modules:

- `shell`: zsh configs and shell related packages to make those configurations work.
- `nvidia`: configures and installs the drivers for nvidia gpus on nixos.

Inividual modules are meant to be imported into System configurations.

### Systems

Specific workstation configurations are stored in the `./config/systems/` directory.

- Configurations are in a subdirectory with a system specific name.
- Subdirectory must contain a `configuration.nix` file.
  - Specific modules are imported from the `modules` directory.
  - You will probably want to import `modules/common/__base.nix`.
- Hardware and workstations specific configurations should be defined here instead of in `modules`.

## Installing

### Nixos

If you're running the NixOS live install medium, use the live medium's built in installer. If you'd rather not, you could also use `__scripts/nixos/nixos-os-installer.sh` to help install NixOS.

If NixOS is already installed, you don't need to do anything else to install nix.

### OSX

If you're using OSX, you can use the scripts in `__scripts/darwin/` to get you started. 

I would recommend doing following:

1. `__scripts/darwin/nix-drive.sh`
    - This script will create a separate mount point for nix at `/nix`
2. `__scripts/darwin/nix-install.sh`
    - This script will install nix if the previous script created `/nix`
3. `__scripts/darwin/nix-darwin-install.sh`
    - This script will install nix-darwin using nix.

## Initializing your configuraiton

For the initial configuration of your system you need to run the following command from the project directory.

```
init.sh [system name]
```

This command will:
- Link the paths to use your system specific `configuration.nix` files as the global configuration file on the system.
  - This makes it so that running `nixos-rebuild` or `darwin-rebuild` use your `configuration.nix` file instead of the default one.
- Run the nix build command which will configure your system.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix Home Manager-based dotfiles repository for a WSL development environment. It uses Nix flakes to declaratively manage the user environment, shell configuration, and development tools.

## Commands

### Apply Configuration Changes

```bash
# Quick reload (shell alias)
reload

# Or explicitly
home-manager switch --flake ~/dotfiles/home-manager#$USER
```

### Initial Setup

```bash
# Full installation (includes Nix, home-manager setup)
./install.sh

# Just home-manager setup (if Nix already installed)
./setup-home-manager.sh
```

### Update Dependencies

```bash
cd ~/dotfiles/home-manager
nix flake update
```

## Architecture

### Directory Structure

- `home-manager/` - Nix Home Manager configuration
  - `flake.nix` - Flake entry point, defines inputs and outputs
  - `home.nix` - Main configuration, imports modules and defines packages
  - `modules/` - Modular configurations split by concern
- `mise/` - Global mise (runtime version manager) configuration
- `templates/` - Project templates for `.envrc` and `.mise.toml`

### Module Organization

The configuration is split into focused modules in `home-manager/modules/`:

- `shell.nix` - Bash, Starship prompt, direnv, fzf, shell aliases
- `git.nix` - Git configuration, delta diff viewer
- `development.nix` - Neovim, bat
- `secrets.nix` - SSH configuration, AWS config symlinks
- `claude.nix` - Claude Code settings for AWS Bedrock integration

### Key Integrations

**1Password SSH Agent**: The shell configuration relays SSH connections through the Windows 1Password agent via `npiperelay.exe`. The socket is at `~/.1password/agent.sock`.

**AWS SSO**: The `claude` shell function wrapper automatically runs `aws sso login --profile sso-bedrock` if the SSO session has expired before launching Claude Code.

**mise + direnv**: Used together for per-project tool versions. The shell defines a `use_mise` function for direnv that activates mise-managed tools. Global mise config is symlinked from `mise/config.toml`.

## Nix-Specific Notes

- Uses `nixos-unstable` channel
- Unfree packages explicitly allowed: `1password-cli`
- State version: `24.05`
- Target system: `x86_64-linux` (WSL)

## When Modifying

- After editing any `.nix` file, run `reload` to apply changes
- Test syntax before applying: `nix flake check ~/dotfiles/home-manager`
- New packages go in `home.nix` under `home.packages`
- Shell aliases and functions go in `modules/shell.nix`
- New modules should be added to the `imports` array in `home.nix`

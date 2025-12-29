# Overview

This is a Nix Home Manager-based dotfiles repository for a WSL development environment. 
It uses Nix flakes to declaratively manage the user environment, shell configuration, and development tools.
It uses Mise to handle tools and libraries. 

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

# Use and contribution 

As you can see from the CLAUDE.md file this was created with the help of the Claude Code LLM. 
The software is mainly for my use, but if you want to use if for inspiration feel free, just dont blame me if you dont like what it does.

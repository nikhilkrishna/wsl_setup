# WSL Dotfiles

Nix Home Manager-based dotfiles for a WSL development environment. Uses Nix flakes for declarative configuration and Mise for runtime version management.

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/nikhilkrishna/wsl_setup.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Edit `home-manager/user-config.nix`** with your details:
   - `username` - your WSL/Linux username (run `whoami`)
   - `windowsUsername` - your Windows username (run `cmd.exe /c "echo %USERNAME%"`)
   - `git.name` and `git.email` - your Git identity
   - `aws.profile` and `aws.region` - for Claude Code with AWS Bedrock (optional)
   - `kafka.*` - Kafka broker URLs if using the Kafka module (optional)

3. **Run the installer:**
   ```bash
   ./install.sh
   ```

4. **Restart your shell:**
   ```bash
   exec $SHELL
   ```

## Commands

### Apply Configuration Changes

```bash
# Quick reload (shell alias)
reload

# Or explicitly
home-manager switch --flake ~/dotfiles/home-manager#$USER
```

### Update Dependencies

```bash
cd ~/dotfiles/home-manager
nix flake update
```

## What's Included

- **Shell**: Bash with Starship prompt, direnv, fzf integration
- **Git**: Configured with delta for better diffs
- **Editor**: Neovim with sensible defaults
- **Tools**: Modern CLI replacements (eza, ripgrep, fd, bat)
- **1Password**: SSH agent relay from Windows (see `docs/ssh-setup.md`)
- **AWS**: SSO integration for Claude Code with Bedrock 
- **Docker**: Native daemon with lazydocker TUI (see `docs/docker-setup.md`)
- **Kafka**: CLI tools with SSL/TLS support (see `docs/kafka-setup.md`)

## Documentation

- `docs/docker-setup.md` - Docker setup with WSL2 networking
- `docs/kafka-setup.md`  - Kafka CLI setup guide
- `docs/java-setup.md`   - JVM setup guide
- `docs/ssh-setup.md`    - SSH setup guide

## License and Use

Created with the help of Claude Code. Free to use for inspiration - no warranties provided.

#!/bin/bash
set -euo pipefail

echo "=========================================="
echo "Setting up Home Manager"
echo "=========================================="

GREEN='\033[0;32m'
NC='\033[0m'
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }

# Ensure Nix is available
if ! command -v nix &> /dev/null; then
    echo "Nix is not installed. Run bootstrap.sh first."
    exit 1
fi

# Navigate to home-manager config
cd ~/dotfiles/home-manager

# Initialize git repo in parent dotfiles directory if not exists
if [ ! -d ~/dotfiles/.git ]; then
    log_info "Initializing git repository..."
    cd ~/dotfiles
    git init
    git add .
    git commit -m "Initial home-manager configuration"
    cd ~/dotfiles/home-manager
fi

# First build - this will download everything
log_info "Building home-manager configuration (this may take a while on first run)..."
nix build .#homeConfigurations.$USER.activationPackage --no-link

# Apply the configuration
log_info "Applying configuration..."
nix run .#homeConfigurations.$USER.activationPackage

# Generate the lock file
log_info "Generating flake.lock..."
nix flake update

# Add lock file to git
cd ~/dotfiles
git add home-manager/flake.lock
git commit -m "Add flake.lock" || true

# Setup mise config symlink
# log_info "Setting up mise configuration symlink..."
# mkdir -p ~/.config/mise
# ln -sf ~/dotfiles/mise/config.toml ~/.config/mise/config.toml

log_info "Home Manager setup complete!"
echo ""
echo "Your environment is ready. Restart your shell:"
echo "  exec \$SHELL"
echo ""
echo "Useful commands:"
echo "  home-manager switch --flake ~/dotfiles/home-manager#\$USER  # Apply changes"
echo "  reload                                                # Alias for above"
echo "  nix flake update                                      # Update all inputs"

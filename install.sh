#!/bin/bash
set -euo pipefail

echo "=========================================="
echo "Complete WSL Dev Environment Installation"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if already fully configured by looking for home-manager generation
if [ -d "$HOME/.local/state/home-manager/gcroots/current-home" ]; then
    echo "Environment already installed. Use 'reload' to apply changes."
    exit 0
fi

# Install essential packages
log_info "Installing essential Ubuntu packages..."
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    curl \
    wget \
    xz-utils \
    git \
    ca-certificates

# Install Nix if not present
if ! command -v nix &> /dev/null; then
    log_info "Installing Nix package manager..."
    sh <(curl -L https://nixos.org/nix/install) --daemon

    # Source nix for current session
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
fi

# Enable flakes
log_info "Enabling Nix flakes..."
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf << 'EOF'
experimental-features = nix-command flakes
EOF

# Verify Nix is working
if ! nix --version &> /dev/null; then
    log_error "Nix not available. Please restart your shell and run this script again."
    echo "Run: exec \$SHELL && ~/dotfiles/install.sh"
    exit 1
fi

# Update username in flake.nix if still placeholder
if grep -q "YOUR_USERNAME" "$SCRIPT_DIR/home-manager/flake.nix"; then
    log_info "Setting username in flake.nix..."
    sed -i "s/YOUR_USERNAME/$USER/g" "$SCRIPT_DIR/home-manager/flake.nix"
fi

# Initialize git repo if not exists (handles case where files were copied, not cloned)
if [ ! -d "$SCRIPT_DIR/.git" ]; then
    log_info "Initializing git repository..."
    cd "$SCRIPT_DIR"
    git init
    git add .
    git commit -m "Initial home-manager configuration"
fi

# Run home-manager setup
log_info "Setting up home-manager..."
cd "$SCRIPT_DIR/home-manager"

# Build and apply
nix build .#homeConfigurations.$USER.activationPackage --no-link
nix run .#homeConfigurations.$USER.activationPackage

# Generate lock file
nix flake update

# Setup mise config symlink
# mkdir -p ~/.config/mise
# ln -sf "$SCRIPT_DIR/mise/config.toml" ~/.config/mise/config.toml

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Restart your shell: exec \$SHELL"
echo "  2. Update your git config in ~/dotfiles/home-manager/modules/git.nix"
echo "  3. Configure your AWS SSO in ~/dotfiles/home-manager/modules/secrets.nix"
echo "  4. Uncomment tools you need in ~/dotfiles/mise/config.toml"
echo ""
echo "Quick reference:"
echo "  reload              - Apply home-manager changes"
echo "  mise install        - Install tools from .mise.toml"
echo "  mise trust          - Trust .mise.toml in current directory"
echo "  direnv allow        - Allow .envrc in current directory"
echo ""
echo "Remember to commit and push your dotfiles!"

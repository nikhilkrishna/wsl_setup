#!/bin/bash
set -euo pipefail

echo "=========================================="
echo "Complete WSL Dev Environment Installation"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

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

# Initialize git repo if not exists (handles case where files were copied, not cloned)
if [ ! -d "$SCRIPT_DIR/.git" ]; then
    log_info "Initializing git repository..."
    cd "$SCRIPT_DIR"
    git init
    git add .
    git commit -m "Initial home-manager configuration"
fi

# ============================================
# Configure user-config.nix
# ============================================
CONFIG_FILE="$SCRIPT_DIR/home-manager/user-config.nix"

configure_user_settings() {
    echo ""
    echo "=========================================="
    echo "User Configuration"
    echo "=========================================="
    echo "Please provide your configuration values."
    echo "Press Enter to keep the suggested default."
    echo ""

    # Get current username as default
    local current_user="$USER"
    read -p "WSL/Linux username [$current_user]: " input_username
    local username="${input_username:-$current_user}"

    # Try to detect Windows username
    local detected_win_user=""
    if command -v cmd.exe &>/dev/null; then
        detected_win_user=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n' || true)
    fi
    local win_user_prompt="Windows username"
    if [ -n "$detected_win_user" ]; then
        win_user_prompt="Windows username [$detected_win_user]"
    fi
    read -p "$win_user_prompt: " input_win_username
    local windows_username="${input_win_username:-$detected_win_user}"

    # Git identity
    local detected_git_name=""
    local detected_git_email=""
    if command -v git &>/dev/null; then
        detected_git_name=$(git config --global user.name 2>/dev/null || true)
        detected_git_email=$(git config --global user.email 2>/dev/null || true)
    fi

    local git_name_prompt="Git name"
    if [ -n "$detected_git_name" ]; then
        git_name_prompt="Git name [$detected_git_name]"
    fi
    read -p "$git_name_prompt: " input_git_name
    local git_name="${input_git_name:-$detected_git_name}"

    local git_email_prompt="Git email"
    if [ -n "$detected_git_email" ]; then
        git_email_prompt="Git email [$detected_git_email]"
    fi
    read -p "$git_email_prompt: " input_git_email
    local git_email="${input_git_email:-$detected_git_email}"

    # Claude Code AWS settings (optional)
    echo ""
    echo "Claude Code settings (AWS Bedrock - press Enter to skip):"
    read -p "Claude AWS SSO profile [your-sso-profile]: " input_aws_profile
    local aws_profile="${input_aws_profile:-your-sso-profile}"

    read -p "Claude AWS region [us-east-1]: " input_aws_region
    local aws_region="${input_aws_region:-us-east-1}"

    # Kafka settings (optional)
    echo ""
    echo "Kafka settings (press Enter to skip if not using Kafka):"
    read -p "Staging broker URL [your-staging-broker.example.com:9092]: " input_kafka_staging
    local kafka_staging="${input_kafka_staging:-your-staging-broker.example.com:9092}"

    read -p "Live broker URL [your-live-broker.example.com:9092]: " input_kafka_live
    local kafka_live="${input_kafka_live:-your-live-broker.example.com:9092}"

    # Update the config file
    log_info "Updating user-config.nix..."

    sed -i "s/username = \"YOUR_USERNAME\";/username = \"$username\";/" "$CONFIG_FILE"
    sed -i "s/windowsUsername = \"YOUR_WINDOWS_USERNAME\";/windowsUsername = \"$windows_username\";/" "$CONFIG_FILE"
    sed -i "s/name = \"Your Name\";/name = \"$git_name\";/" "$CONFIG_FILE"
    sed -i "s/email = \"your.email@example.com\";/email = \"$git_email\";/" "$CONFIG_FILE"
    sed -i "s/awsProfile = \"your-sso-profile\";/awsProfile = \"$aws_profile\";/" "$CONFIG_FILE"
    sed -i "s/awsRegion = \"us-east-1\";/awsRegion = \"$aws_region\";/" "$CONFIG_FILE"
    sed -i "s/broker = \"your-staging-broker.example.com:9092\";/broker = \"$kafka_staging\";/" "$CONFIG_FILE"
    sed -i "s/broker = \"your-live-broker.example.com:9092\";/broker = \"$kafka_live\";/" "$CONFIG_FILE"

    echo ""
    log_info "Configuration saved!"
}

# Check if user-config.nix needs to be configured
if grep -q 'username = "YOUR_USERNAME"' "$CONFIG_FILE"; then
    configure_user_settings
else
    log_info "user-config.nix already configured, skipping..."
fi

# Run home-manager setup
log_info "Setting up home-manager..."
cd "$SCRIPT_DIR/home-manager"

# Build and apply
log_info "Building home-manager configuration (this may take a while on first run)..."
nix build .#homeConfigurations.$USER.activationPackage --no-link
nix run .#homeConfigurations.$USER.activationPackage

# Generate lock file
nix flake update

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Restart your shell: exec \$SHELL"
echo "  2. (Optional) Edit ~/dotfiles/home-manager/user-config.nix to adjust settings"
echo "  3. (Optional) Uncomment tools you need in ~/dotfiles/mise/config.toml"
echo ""
echo "Quick reference:"
echo "  reload              - Apply home-manager changes"
echo "  mise install        - Install tools from .mise.toml"
echo "  mise trust          - Trust .mise.toml in current directory"
echo "  direnv allow        - Allow .envrc in current directory"

#!/bin/bash
set -euo pipefail

echo "=========================================="
echo "Setting up Home Manager"
echo "=========================================="

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Ensure Nix is available
if ! command -v nix &> /dev/null; then
    echo "Nix is not installed. Run install.sh first."
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

# ============================================
# Configure user-config.nix
# ============================================
CONFIG_FILE="$HOME/dotfiles/home-manager/user-config.nix"

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

log_info "Home Manager setup complete!"
echo ""
echo "Your environment is ready. Restart your shell:"
echo "  exec \$SHELL"
echo ""
echo "Useful commands:"
echo "  home-manager switch --flake ~/dotfiles/home-manager#\$USER  # Apply changes"
echo "  reload                                                # Alias for above"
echo "  nix flake update                                      # Update all inputs"

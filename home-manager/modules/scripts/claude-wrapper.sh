# claude-wrapper.sh - Claude Code with AWS SSO pre-authentication
# Note: $profile variable is set by the calling function from Nix config

# Check if SSO session is valid for Claude's profile
if ! aws sts get-caller-identity --profile "$profile" &>/dev/null; then
  echo "AWS SSO session expired for Claude ($profile). Logging in..."
  aws sso login --profile "$profile"
fi

# Run the actual claude command
command claude "$@"

{ config, pkgs, lib, userConfig, ... }:

{
  # ============================================
  # Claude Code Configuration
  # ============================================
  # Manages ~/.claude/settings.json for AWS Bedrock integration
  # Uses SSO authentication with the configured AWS profile

  home.file.".claude/settings.json".text = builtins.toJSON {
    awsAuthRefresh = "aws sso login --profile ${userConfig.claude.awsProfile}";
    env = {
      AWS_PROFILE = userConfig.claude.awsProfile;
      CLAUDE_CODE_USE_BEDROCK = "1";
      AWS_REGION = userConfig.claude.awsRegion;
      ANTHROPIC_MODEL = "global.anthropic.claude-opus-4-5-20251101-v1:0";
    };
    enabledPlugins = {
      "example-plugin@claude-plugins-official" = true;
      "greptile@claude-plugins-official" = true;
      "pr-review-toolkit@claude-plugins-official" = true;
      "plugin-dev@claude-plugins-official" = true;
      "ralph-wiggum@claude-plugins-official" = true;
      "serena@claude-plugins-official" = true;
    };
  };
}

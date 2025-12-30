{ config, pkgs, lib, ... }:

{
  # ============================================
  # Claude Code Configuration
  # ============================================
  # Manages ~/.claude/settings.json for AWS Bedrock integration
  # Uses SSO authentication with the sso-bedrock profile

  home.file.".claude/settings.json".text = builtins.toJSON {
    awsAuthRefresh = "aws sso login --profile sso-bedrock";
    env = {
      AWS_PROFILE = "sso-bedrock";
      CLAUDE_CODE_USE_BEDROCK = "1";
      AWS_REGION = "eu-west-1";
      ANTHROPIC_MODEL = "global.anthropic.claude-opus-4-5-20251101-v1:0";
    };
    enabledPlugins = {
      "greptile@claude-plugins-official" = true;
      "pr-review-toolkit@claude-plugins-official" = true;
      "plugin-dev@claude-plugins-official" = true;
      "ralph-wiggum@claude-plugins-official" = true;
      "serena@claude-plugins-official" = true;
      # Local plugin for extracting elaborate comments to documentation
      "comment-extractor" = true;
    };
  };
}

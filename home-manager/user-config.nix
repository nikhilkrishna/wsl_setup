# User Configuration
# Edit these values to match your environment
{
  # WSL/Linux username (run: whoami)
  username = "YOUR_USERNAME";

  # Windows username for symlinks (run: cmd.exe /c "echo %USERNAME%")
  windowsUsername = "YOUR_WINDOWS_USERNAME";

  # Git identity
  git = {
    name = "Your Name";
    email = "your.email@example.com";
  };

  # Claude Code settings (AWS Bedrock)
  claude = {
    awsProfile = "your-sso-profile";
    awsRegion = "us-east-1";
  };

  # Kafka broker URLs (from your Kafka provider)
  kafka = {
    staging = {
      broker = "your-staging-broker.example.com:9092";
    };
    live = {
      broker = "your-live-broker.example.com:9092";
    };
  };
}

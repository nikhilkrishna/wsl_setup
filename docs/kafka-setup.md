# Kafka CLI Setup

This guide explains how to set up Kafka CLI tools for use with SSL/TLS authentication in WSL.

## Prerequisites

1. **Kafka provider account** with SSL certificate authentication (e.g., Aiven, Confluent Cloud)
2. **SSL certificates** from your Kafka provider:
   - CA certificate (`ca.pem`)
   - Client certificate (`service.cert`)
   - Client private key (`service.key`)

## Windows Folder Structure

Create the following folder structure on your Windows filesystem:

```
C:\Users\<YOUR_WINDOWS_USERNAME>\.kafka\
└── certs\
    ├── staging\
    │   ├── ca.pem
    │   ├── service.cert
    │   └── service.key
    └── live\
        ├── ca.pem
        ├── service.cert
        └── service.key
```

The certificates are stored on the Windows side so they can be shared with Windows-native tools if needed. The Nix configuration symlinks this directory to `~/.kafka/certs` in WSL.

## Configuration

### 1. Update user-config.nix

Add your Kafka broker URLs to `home-manager/user-config.nix`:

```nix
kafka = {
  staging = {
    broker = "your-staging-broker.example.com:9092";
  };
  live = {
    broker = "your-live-broker.example.com:9092";
  };
};
```

### 2. Apply configuration

```bash
reload
```

This will:
- Symlink the Windows certificates directory to `~/.kafka/certs`
- Generate Kafka properties files in `~/.kafka/staging/` and `~/.kafka/live/`
- Create the kafkactl configuration in `~/.config/kafkactl/config.yml`

### Native Kafka Tools

Configuration files are generated at:
- `~/.kafka/staging/config.properties`
- `~/.kafka/live/config.properties`

These use PEM-based SSL configuration with paths pointing to the WSL symlinked certificates.

### kafkactl

kafkactl uses a YAML configuration at `~/.config/kafkactl/config.yml` with named contexts:

```bash
# Switch to staging
kafkactl config use-context staging

# Switch to live (default)
kafkactl config use-context live
```

## Related Files

- `home-manager/modules/kafka.nix` - Kafka tools and configuration

## Usage

### Using kafkactl (recommended)

kafkactl provides a modern CLI with context switching:

```bash
# Switch to staging environment
kafkactl config use-context staging

# List topics
kafkactl get topics

# Describe a topic
kafkactl describe topic my-topic

# Consume messages
kafkactl consume my-topic --from-beginning --exit

# Switch to live environment
kafkactl config use-context live

# List topics
kafkactl get topics

# Describe consumer group
kafkactl describe consumer-group my-group
```

### Using native Kafka scripts

The native Kafka scripts require specifying the config file:

```bash
# List topics (staging)
kafka-topics.sh --bootstrap-server your-staging-broker:9092 \
  --command-config ~/.kafka/staging/config.properties \
  --list

# List consumer groups (live)
kafka-consumer-groups.sh --bootstrap-server your-live-broker:9092 \
  --command-config ~/.kafka/live/config.properties \
  --list
```

## Troubleshooting

### SSL handshake errors

Ensure your certificates are in PEM format and the paths in the config match your actual file structure.

### Connection refused

1. Check that your IP is allowlisted in your Kafka provider's access controls
2. Verify the broker URL and port are correct
3. Test connectivity: `nc -zv your-broker.example.com 9092`

### Certificate expired

Download fresh certificates from your Kafka provider and replace the files in the Windows certificates directory.

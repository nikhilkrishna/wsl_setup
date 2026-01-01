# Java Ecosystem Setup

This guide explains how to set up Java, Kotlin, and Gradle for Spring Boot projects using mise.

## Overview

Java tooling is managed per-project via mise, not globally. Each project specifies its JDK and Gradle versions in `.mise.toml`, and direnv activates them when you enter the project directory.

## Quick Start

1. Copy the templates to your project:
   ```bash
   cp ~/dotfiles/templates/mise.toml.template myproject/.mise.toml
   cp ~/dotfiles/templates/envrc.template myproject/.envrc
   ```

2. Edit `.mise.toml` to enable Java:
   ```toml
   [tools]
   java = "temurin-21"
   gradle = "8.5"
   ```

3. Allow direnv:
   ```bash
   cd myproject
   direnv allow
   ```

4. Verify:
   ```bash
   java -version
   echo $JAVA_HOME
   ```

## Available JDK Distributions

mise supports multiple JDK distributions via the `java` tool:

| Distribution | Example | Notes |
|-------------|---------|-------|
| Eclipse Temurin | `temurin-21` | Recommended, drop-in Oracle replacement |
| Amazon Corretto | `corretto-21` | AWS-optimized with LTS |
| Azul Zulu | `zulu-21` | Enterprise-grade builds |
| GraalVM | `graalvm-21` | High-performance, native-image support |
| OpenJDK | `openjdk-21` | Reference implementation |

### Common LTS Versions

- `temurin-21` - Latest LTS (recommended for new projects)
- `temurin-17` - Previous LTS (widely supported)
- `temurin-11` - Legacy LTS (older projects)

## Spring Boot + Kotlin + Gradle Example

Example `.mise.toml` for a typical Spring Boot Kotlin project:

```toml
[tools]
java = "temurin-21"
gradle = "8.5"

[env]
# Optional: Spring profiles
SPRING_PROFILES_ACTIVE = "local"
```

Example `.envrc`:

```bash
use mise

# Project-isolated Gradle cache
export GRADLE_USER_HOME="${PWD}/.gradle"
export GRADLE_OPTS="-Dorg.gradle.daemon=true -Xmx2g"

# Spring Boot settings
export SPRING_PROFILES_ACTIVE=local
```

## Gradle Configuration

### Gradle Wrapper vs mise-managed Gradle

You have two options:

1. **Gradle Wrapper (recommended for teams)**: Use `./gradlew` - version is defined in `gradle/wrapper/gradle-wrapper.properties`
2. **mise-managed Gradle**: Add `gradle = "8.5"` to `.mise.toml` - ensures consistent `gradle` command

Both can coexist. The wrapper is preferred for CI/CD and team consistency.

### Project-Isolated Cache

To keep dependencies isolated per project (at the cost of re-downloading):

```bash
export GRADLE_USER_HOME="${PWD}/.gradle"
```

Add `.gradle/` to your `.gitignore`.

### Gradle Daemon

Enable the daemon for faster builds:

```bash
export GRADLE_OPTS="-Dorg.gradle.daemon=true -Xmx2g"
```

## IDE Integration

### IntelliJ IDEA

IntelliJ automatically detects `JAVA_HOME` when set. To ensure it uses the mise-managed JDK:

1. Open project in IntelliJ
2. Go to **File > Project Structure > Project**
3. SDK should auto-detect, or click **Add SDK > Download JDK** and select the mise path

The mise JDK path is typically: `~/.local/share/mise/installs/java/<version>`

### VS Code

Install the "Extension Pack for Java" and configure:

```json
{
  "java.configuration.runtimes": [
    {
      "name": "JavaSE-21",
      "path": "${env:JAVA_HOME}",
      "default": true
    }
  ]
}
```

## Troubleshooting

### `java` command not found

Ensure mise is activated in your shell:
```bash
eval "$(mise activate bash)"
```

Or verify the project has a `.mise.toml` with java specified.

### Wrong Java version

Check which version mise is using:
```bash
mise current java
mise list java
```

### Gradle uses wrong JDK

Verify `JAVA_HOME` is set:
```bash
echo $JAVA_HOME
./gradlew --version
```

The Gradle output shows which JDK it's using.

### mise trust required

If you see a trust warning:
```bash
mise trust
```

Projects in `~/workspace` are auto-trusted (configured in global mise config).

## Related Files

- `templates/mise.toml.template` - Project mise configuration template
- `templates/envrc.template` - Project direnv configuration template
- `mise/config.toml` - Global mise configuration

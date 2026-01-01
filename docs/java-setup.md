# Java Ecosystem Setup

Java tooling is managed per-project via mise. Each project specifies its JDK and Gradle versions in `.mise.toml`.

## Quick Start

1. Copy templates and configure:
   ```bash
   cp ~/dotfiles/templates/mise.toml.template myproject/.mise.toml
   cp ~/dotfiles/templates/envrc.template myproject/.envrc
   ```

2. Edit `.mise.toml`:
   ```toml
   [tools]
   java = "temurin-21"
   gradle = "9.2"
   ```

3. Edit `.envrc` (uncomment Java section):
   ```bash
   use mise
   export GRADLE_USER_HOME="${PWD}/.gradle"
   export GRADLE_OPTS="-Dorg.gradle.daemon=true -Xmx2g"
   ```

4. Activate and verify:
   ```bash
   cd myproject && direnv allow
   java -version && echo $JAVA_HOME
   ```

## JDK Distributions

| Distribution | Example | Notes |
|-------------|---------|-------|
| Eclipse Temurin | `temurin-21` | Recommended |
| Amazon Corretto | `corretto-21` | AWS-optimized |
| Azul Zulu | `zulu-21` | Enterprise builds |
| GraalVM | `graalvm-21` | Native-image support |

Common versions: `temurin-21` (LTS), `temurin-17` (LTS), `temurin-11` (legacy)

## Gradle Wrapper

The wrapper (`./gradlew`) downloads its own Gradle but uses `JAVA_HOME` for the JDK. Since mise sets `JAVA_HOME`, there's no conflict - both wrapper and mise-managed Gradle use the same JDK.

**Recommendation:** Use wrapper for Gradle version, mise for JDK version.

## IntelliJ IDEA (WSL)

IntelliJ on Windows doesn't see direnv/mise environment variables when using WSL integration.

**Setup:**
1. Get JDK path: `mise where java`
2. In IntelliJ: **Settings > Build Tools > Gradle > Gradle JVM > Add JDK**
3. Enter WSL path:
   ```
   \\wsl$\Ubuntu\home\<username>\.local\share\mise\installs\java\<version>
   ```

**Note:** Update this path when changing JDK versions. Windows cannot follow Linux symlinks through `\\wsl$`.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `java` not found | Check `.mise.toml` has java specified |
| Wrong Java version | Run `mise current java` to verify |
| Gradle uses wrong JDK | Check `./gradlew --version` shows correct JDK |
| mise trust warning | Run `mise trust` (auto-trusted in `~/workspace`) |

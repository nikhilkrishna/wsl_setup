# SSH Setup

> Extracted from `home-manager/modules/shell.nix` and `home-manager/modules/secrets.nix`

## 1Password SSH Agent Relay (Windows to WSL)

This configuration enables using the 1Password SSH agent from Windows within WSL.

### Prerequisites (on Windows)

1. **1Password desktop** with SSH Agent enabled
   - Open 1Password Settings → Developer
   - Enable "Use the SSH agent"

2. **npiperelay** installed via one of:
   ```powershell
   # Using winget (recommended)
   winget install albertony.npiperelay

   # OR using scoop
   scoop install npiperelay
   ```

### How It Works

The shell initialization script (`shell.nix`) sets up a relay between:
- **Windows**: 1Password's named pipe at `//./pipe/openssh-ssh-agent`
- **WSL**: Unix socket at `~/.1password/agent.sock`

The relay uses `socat` and `npiperelay.exe` to bridge the two. The script:
1. Locates `npiperelay.exe` (checks PATH, common install locations)
2. Creates the socket directory at `~/.1password/`
3. Starts a background `socat` process to relay connections
4. Automatically restarts the relay if the socket is missing or unresponsive

### Environment Variable

```bash
export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
```

## SSH Configuration

The SSH configuration in `secrets.nix` includes:

| Setting | Value | Purpose |
|---------|-------|---------|
| `IdentityAgent` | `~/.1password/agent.sock` | Use 1Password for SSH keys |
| `ControlMaster` | `auto` | Connection sharing |
| `ControlPath` | `~/.ssh/sockets/%r@%h-%p` | Socket path for shared connections |
| `ControlPersist` | `600` | Keep connections alive for 10 minutes |
| `ServerAliveInterval` | `60` | Send keepalive every 60 seconds |
| `ServerAliveCountMax` | `3` | Disconnect after 3 missed keepalives |
| `AddKeysToAgent` | `yes` | Automatically add keys to agent |

## Related Files

- `home-manager/modules/shell.nix` - Shell initialization and relay script
- `home-manager/modules/secrets.nix` - SSH client configuration

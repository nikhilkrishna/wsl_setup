# Docker Setup in WSL2

Native Docker daemon setup for WSL2 with systemd.

## Setup Steps

### 1. Enable systemd in WSL2

**Check if already enabled:**
```bash
ps -p 1 -o comm=
```

If output is `systemd`, skip to Step 2. Otherwise, add to `/etc/wsl.conf`:

```ini
[boot]
systemd=true
```

Then restart WSL: `wsl --shutdown` (from PowerShell)

### 2. Apply Nix configuration

```bash
reload
```

Installs: `docker` CLI, `docker-compose`, `lazydocker`

### 3. Install Docker daemon

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh
```

> **Note:** Ignore the "WSL DETECTED: We recommend Docker Desktop" message.

### 4. Configure user permissions

```bash
sudo usermod -aG docker $USER
newgrp docker  # or log out/in
```

### 5. Verify

```bash
docker run hello-world
```

## Shell Aliases

| Alias | Command |
|-------|---------|
| `d` | `docker` |
| `dc` | `docker compose` |
| `dps` | `docker ps` |
| `dpsa` | `docker ps -a` |
| `lzd` | `lazydocker` |

## Accessing Docker Services from Windows

To connect to Docker containers from Windows applications (e.g., SSMS, database clients):

### 1. Enable mirrored networking

Add to `C:\Users\<username>\.wslconfig`:

```ini
[wsl2]
networkingMode=mirrored
```

Restart WSL: `wsl --shutdown`

### 2. Use `127.0.0.1` instead of `localhost`

Windows applications may resolve `localhost` to IPv6 (`::1`) while Docker binds to IPv4. Use `127.0.0.1` explicitly.

**Example - SSMS connection to SQL Server container:**
- Server: `127.0.0.1,1433` (or `tcp:127.0.0.1,1433`)
- Authentication: SQL Server Authentication

## Related Files

- `home-manager/modules/docker.nix` - Docker packages
- `home-manager/modules/shell.nix` - Docker aliases

## Troubleshooting

### "Cannot connect to the Docker daemon"

```bash
sudo systemctl status docker  # Check status
sudo systemctl start docker   # Start if not running
```

### "Permission denied" errors

```bash
groups  # Verify 'docker' is listed
```

If not, re-run Step 4 and log out/in.

### WSL resource limits

Configure in `C:\Users\<username>\.wslconfig`:

```ini
[wsl2]
memory=16GB
processors=6
swap=24GB
networkingMode=mirrored
```

# Installation Instructions

A comprehensive guide to installing and configuring Terminal Banner on macOS, Linux, and LXC containers.

---

## Quick Install

### macOS / Linux / Raspberry Pi

```bash
# Clone the repository
git clone https://github.com/yourusername/terminalBanner.git
cd terminalBanner

# Run the installer
./install.sh
```

That's it! The banner will appear when you open a new terminal.

---

## What the Installer Does

1. Detects your shell (bash or zsh)
2. Creates `~/.config/terminal-banner/` directory
3. Copies all scripts and configuration files
4. Adds 3 lines to your `.bashrc` or `.zshrc`:
   ```bash
   # ============ Terminal Banner ============
   [ -f "$HOME/.config/terminal-banner/banner.sh" ] && source "$HOME/.config/terminal-banner/banner.sh"
   alias banner-toggle="$HOME/.config/terminal-banner/banner-toggle.sh"
   # ============ End Terminal Banner ============
   ```

---

## Platform-Specific Notes

### macOS

#### Basic Installation (No Dependencies)
Works out of the box with basic system information:
- ✅ Hostname, uptime, network IP
- ✅ CPU usage, memory, disk usage
- ❌ CPU temperature (requires optional tools)

#### Optional: Enable More Features

**ASCII Art Hostname:**
```bash
brew install figlet
```

**WAN IP Detection:**
```bash
brew install curl jq
```

**CPU Temperature (Apple Silicon Note):**
```bash
# Try these, but they often don't work on M1/M2/M3 Macs:
brew install osx-cpu-temp
# or
sudo gem install iStats

# If neither works, disable CPU temp:
nano ~/.config/terminal-banner/banner.conf
# Set: SHOW_CPU_TEMP=false
```

**Known Issue:** CPU temperature detection is problematic on Apple Silicon (M1/M2/M3) Macs due to sensor access restrictions. We recommend disabling it.

---

### Linux / Raspberry Pi / DietPi

#### Debian/Ubuntu/DietPi
```bash
# Basic installation - works with no dependencies

# Optional features:
sudo apt install figlet curl jq     # For ASCII art and WAN IP
sudo apt install lm-sensors         # For better CPU temp on some systems
```

#### Other Linux Distributions
Replace `apt` with your package manager:
- **Fedora/RHEL:** `sudo dnf install figlet curl jq`
- **Arch:** `sudo pacman -S figlet curl jq`

---

### LXC Containers (Proxmox)

Perfect for showing service information!

1. **Install in each container:**
   ```bash
   git clone https://github.com/yourusername/terminalBanner.git
   cd terminalBanner
   ./install.sh
   ```

2. **Configure services:**
   ```bash
   nano ~/.config/terminal-banner/services.conf
   ```

3. **The banner will auto-detect running services** (Plex, Sonarr, Radarr, etc.)

Example for a Plex container:
```
─────────────────────────────────────────────────────
Container: plex-server : 09:15 - Wed 12/31/25
─────────────────────────────────────────────────────
- Service      : Plex Media Server
- Access URL   : http://192.168.1.150:32400
- Web UI       : http://192.168.1.150:32400/web
- CPU Usage    : 5%
- Memory       : 2.1GB / 4GB (52%)
─────────────────────────────────────────────────────
```

---

## Configuration

### Basic Configuration

Edit `~/.config/terminal-banner/banner.conf`:

```bash
# Enable/disable the banner
ENABLED=true

# What to display
SHOW_SEPARATOR=true
SHOW_TIMESTAMP=true
SHOW_CPU_TEMP=false        # Disable on Apple Silicon Macs
SHOW_NETWORK=true
SHOW_RESOURCES=true
SHOW_DISK_USAGE=true

# Optional features (require dependencies)
CLEAR_SCREEN=false          # Clear screen before banner
SHOW_HOSTNAME_ASCII=false   # ASCII art (requires figlet)
SHOW_WAN_IP=false          # Public IP (requires curl, jq)
SHOW_VPN_STATUS=false      # VPN detection

# Appearance
USE_COLORS=true
COLOR_PRIMARY="GREEN"
COLOR_ACCENT="BLUE"
```

### Service Configuration (LXC Containers)

Edit `~/.config/terminal-banner/services.conf`:

```bash
# Format: SERVICE_NAME|IP|PORT|DESCRIPTION|WEB_PATH
# Leave IP empty for auto-detection

PLEX||32400|Plex Media Server|/web
SONARR||8989|TV Show Management|
RADARR||7878|Movie Management|
OVERSEERR||5055|Media Requests|
PIHOLE||80|DNS Ad Blocker|admin
```

---

## Usage

### Commands

**Toggle banner on/off:**
```bash
banner-toggle
```

**Reload banner immediately:**
```bash
source ~/.config/terminal-banner/banner.sh
```

**Edit configuration:**
```bash
nano ~/.config/terminal-banner/banner.conf
```

### Testing Components

Test individual components:
```bash
cd terminalBanner
./test-components.sh
```

---

## Troubleshooting

### Banner not showing
1. Check if enabled: `grep ENABLED ~/.config/terminal-banner/banner.conf`
2. Verify installation: `grep "Terminal Banner" ~/.zshrc` (or `~/.bashrc`)
3. Test manually: `bash -x ~/.config/terminal-banner/banner.sh`

### Showing twice
1. Run diagnostic: `./fix-double-execution.sh`
2. Check for duplicate installations in your shell profile

### CPU temperature shows 0°C (macOS)

**For Apple Silicon (M1/M2/M3 Macs):**

This is a known issue. CPU temperature sensors are not easily accessible on Apple Silicon without special tools that require elevated permissions.

**Solution:** Disable CPU temperature display:
```bash
nano ~/.config/terminal-banner/banner.conf
# Set: SHOW_CPU_TEMP=false
```

Alternatively, use a menu bar app:
```bash
brew install stats  # Visual system monitor with temp
```

### Disk usage incorrect (macOS)

The script automatically detects APFS Data volumes. If you see issues:
```bash
# Check actual disk usage:
df -H /System/Volumes/Data

# Update scripts:
cd terminalBanner
cp lib/system-info.sh ~/.config/terminal-banner/lib/
source ~/.zshrc
```

### Slow startup

1. Disable WAN IP lookup: `SHOW_WAN_IP=false`
2. Disable ASCII art: `SHOW_HOSTNAME_ASCII=false`
3. Check network timeout issues

---

## Updating

### Update to latest version
```bash
cd terminalBanner
git pull
./update-to-minimal.sh  # Updates all installed scripts
```

### Manual update
```bash
cd terminalBanner
cp banner.sh ~/.config/terminal-banner/
cp lib/*.sh ~/.config/terminal-banner/lib/
source ~/.zshrc
```

---

## Uninstallation

```bash
cd terminalBanner
./uninstall.sh
```

This will:
1. Remove banner code from your shell profile
2. Optionally delete `~/.config/terminal-banner/`
3. Create a backup before making changes

---

## Platform-Specific Installation Examples

### Raspberry Pi Zero 2W (DietPi)
```bash
# No dependencies needed for basic banner
git clone https://github.com/yourusername/terminalBanner.git
cd terminalBanner
./install.sh

# Optional: Add ASCII art
sudo apt install figlet
nano ~/.config/terminal-banner/banner.conf
# Set: SHOW_HOSTNAME_ASCII=true
```

### MacBook Pro (M2 Pro)
```bash
# Clone and install
git clone https://github.com/yourusername/terminalBanner.git
cd terminalBanner
./install.sh

# Disable CPU temp (doesn't work reliably on M2)
nano ~/.config/terminal-banner/banner.conf
# Set: SHOW_CPU_TEMP=false

# Optional: Add features
brew install figlet curl jq
nano ~/.config/terminal-banner/banner.conf
# Set: SHOW_HOSTNAME_ASCII=true
# Set: SHOW_WAN_IP=true
```

### Proxmox LXC Container (Ubuntu)
```bash
# In each container
git clone https://github.com/yourusername/terminalBanner.git
cd terminalBanner
./install.sh

# Services auto-detected via port scanning
# Customize in ~/.config/terminal-banner/services.conf
```

---

## Dependencies Summary

| Feature | macOS | Linux | Required? |
|---------|-------|-------|-----------|
| Basic banner | ✅ Built-in | ✅ Built-in | Yes |
| CPU temp | ⚠️ osx-cpu-temp / iStats | ✅ Built-in | Optional |
| ASCII art | figlet | figlet | Optional |
| WAN IP | curl + jq | curl + jq | Optional |
| Service detection | N/A | Built-in | Auto |

---

## Getting Help

1. Check the main [README.md](README.md)
2. Run diagnostic scripts:
   - `./test-components.sh`
   - `./fix-double-execution.sh`
   - `./fix-apple-silicon.sh` (macOS only)
3. Open an issue on GitHub with:
   - Your OS and shell type
   - Output of `bash -x ~/.config/terminal-banner/banner.sh`
   - Your banner.conf (with sensitive info removed)

---

## License

MIT License - See [LICENSE](LICENSE) for details


# Terminal Banner

> A cross-platform, customizable terminal banner system that displays system information at login.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20LXC-blue.svg)](https://github.com/yourusername/terminalBanner)
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh-green.svg)](https://github.com/yourusername/terminalBanner)

Inspired by DietPi's terminal banner, this lightweight tool works seamlessly on macOS, Linux (including Raspberry Pi/DietPi), and LXC containers. Show system stats, detect running services, and customize your terminal experience with zero dependencies for core functionality.

## Features

- 🖥️ **Cross-platform**: Works on macOS, Linux (including DietPi/Raspberry Pi), and LXC containers
- 🎨 **Customizable**: Extensive configuration options for colors, display elements, and layout
- 🚀 **Fast**: Minimal startup delay (< 0.5s with optional features disabled)
- 🔍 **Auto-detection**: Automatically detects OS, services, and system information
- 📦 **Zero dependencies**: Core functionality requires only standard Unix tools
- 🎯 **Service detection**: Automatically detects and displays running services in LXC containers
- 🎛️ **Easy toggle**: Enable/disable instantly with a single command
- 🌈 **Optional features**: ASCII art hostname, WAN IP, VPN status, and more

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/terminalBanner.git
cd terminalBanner

# Run the installation script
./install.sh

# The banner will appear on your next terminal session!
```

That's it! No dependencies required for basic functionality.

📖 **[See detailed installation instructions →](INSTALL.md)**

### Usage

The banner will automatically appear when you open a new terminal. To customize:

```bash
# Edit configuration
nano ~/.config/terminal-banner/banner.conf

# Toggle banner on/off
banner-toggle

# Reload shell to see changes
source ~/.zshrc  # or ~/.bashrc
```

## Screenshots

### macOS Banner (Basic)
```
─────────────────────────────────────────────────────
macOS 15.2 : 14:23 - Wed 12/31/25
─────────────────────────────────────────────────────
- Hostname     : MacBook-Pro
- Uptime       : 3 days, 14 hrs, 23 mins
- LAN IP       : 192.168.1.100 (en0)
- CPU Usage    : 15%
- Memory       : 8.2GB / 16.0GB (51%)
- Disk Usage   : 180GB / 500GB (36%)
─────────────────────────────────────────────────────
Quick Commands:
  htop          : System resource monitor
  banner-toggle : Enable/disable this banner
─────────────────────────────────────────────────────
```
*Note: CPU temp disabled on Apple Silicon - see [troubleshooting](#cpu-temperature-not-showing)*

### LXC Container (Plex Server)
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

## Configuration

Edit `~/.config/terminal-banner/banner.conf` to customize your banner:

### Basic Options

```bash
# Enable/disable the banner
ENABLED=true

# Display options
SHOW_SEPARATOR=true
SHOW_TIMESTAMP=true
SHOW_CPU_TEMP=true
SHOW_NETWORK=true
SHOW_RESOURCES=true
SHOW_CUSTOM_COMMANDS=true
SHOW_DISK_USAGE=true
```

### Optional Features

```bash
# Clear screen before showing banner
CLEAR_SCREEN=false

# Show hostname as ASCII art (requires figlet)
SHOW_HOSTNAME_ASCII=false

# Fetch WAN IP from ipinfo.io (requires curl, jq)
# Note: This is cached for 1 hour to avoid delays
SHOW_WAN_IP=false

# Check VPN connection status
SHOW_VPN_STATUS=false
```

### Appearance

```bash
# Terminal width (leave empty for auto-detect)
BANNER_WIDTH=

# Color scheme
USE_COLORS=true
COLOR_PRIMARY="GREEN"     # Primary color for separators and labels
COLOR_ACCENT="BLUE"       # Accent color for highlights
```

### VPN Detection

```bash
# Network interface patterns to check for VPN connections
VPN_INTERFACES="utun tun wg"

# VPN names mapping (optional)
VPN_NAMES="utun8:Work utun9:WireGuard"
```

## Service Configuration (LXC Containers)

Edit `~/.config/terminal-banner/services.conf` to define services running in your LXC containers:

```bash
# Format: SERVICE_NAME|IP|PORT|DESCRIPTION|WEB_PATH
# Leave IP empty for auto-detection

# Media Services
PLEX||32400|Plex Media Server|/web
TAUTULLI||8181|Plex Statistics|
OVERSEERR||5055|Media Requests|

# Media Management
SONARR||8989|TV Show Management|
RADARR||7878|Movie Management|
PROWLARR||9696|Indexer Manager|

# Infrastructure
PORTAINER||9443|Container Management|
HOMEPAGE||3000|Dashboard|
PIHOLE||80|DNS Ad Blocker|admin
WIREGUARD||51821|VPN Dashboard|

# Add your custom services
# MYSERVICE||8080|My Custom Service|
```

The script will automatically detect which services are running by checking if their ports are listening.

## Optional Dependencies

The core banner works with standard Unix tools. Optional features require:

### macOS
```bash
# For ASCII art hostname
brew install figlet

# For WAN IP detection
brew install curl jq

# For accurate CPU temperature
brew install osx-cpu-temp
```

### Linux (Debian/Ubuntu)
```bash
# For ASCII art hostname and WAN IP
sudo apt install figlet curl jq

# For detailed thermal info
sudo apt install lm-sensors
```

**Note**: The script gracefully handles missing dependencies and skips unavailable features.

## Platform Support

### macOS
- ✅ macOS version and architecture
- ✅ CPU temperature (with osx-cpu-temp)
- ✅ Network interfaces (Wi-Fi and Ethernet)
- ✅ CPU and memory usage
- ✅ Disk usage
- ✅ Optional: WAN IP, VPN status, ASCII art

### Linux / Raspberry Pi / DietPi
- ✅ Distribution and kernel version
- ✅ Device model detection (Raspberry Pi, etc.)
- ✅ CPU temperature from thermal sensors
- ✅ Network interfaces (eth0, wlan0, etc.)
- ✅ CPU and memory usage
- ✅ Disk usage

### LXC Containers
- ✅ Container name detection
- ✅ Automatic service detection
- ✅ Service access URLs
- ✅ Resource usage display

## Commands

After installation, these commands are available:

### banner-toggle
Enable or disable the banner:
```bash
banner-toggle
# Output: Terminal banner disabled (takes effect on next login)
```

### Manual reload
See the banner immediately without opening a new terminal:
```bash
source ~/.config/terminal-banner/banner.sh
```

## Uninstallation

To remove the terminal banner:

```bash
cd terminalBanner
./uninstall.sh
```

The uninstaller will:
1. Remove banner code from your shell profile
2. Optionally remove configuration files
3. Create a backup of your profile before making changes

## Troubleshooting

### Banner not showing
1. Check if it's enabled: `grep ENABLED ~/.config/terminal-banner/banner.conf`
2. Verify installation: `grep "Terminal Banner" ~/.zshrc` (or `~/.bashrc`)
3. Check for errors: `bash -x ~/.config/terminal-banner/banner.sh`

### Slow startup
1. Disable WAN IP: Set `SHOW_WAN_IP=false` in config
2. Disable optional features: Set `SHOW_HOSTNAME_ASCII=false`
3. The WAN IP is cached for 1 hour, so it should only be slow once per hour

### CPU temperature not showing

**macOS (Apple Silicon - M1/M2/M3):**

⚠️ **Known Issue:** CPU temperature is difficult to access on Apple Silicon Macs due to sensor restrictions.

**Recommended solution:** Disable it in your config:
```bash
nano ~/.config/terminal-banner/banner.conf
# Set: SHOW_CPU_TEMP=false
```

**Why it doesn't work:**
- `osx-cpu-temp` has IOService permission errors on M-series chips
- `iStats` also fails on many M1/M2/M3 Macs
- `powermetrics` requires sudo (not practical for login banners)

**Alternative:** Use a menu bar app like [Stats](https://github.com/exelban/stats):
```bash
brew install stats
```

**macOS (Intel):** `brew install osx-cpu-temp` usually works

**Linux:** Built-in via `/sys/class/thermal/thermal_zone0/temp` or install `lm-sensors`

### VPN status not detecting
Configure the correct interface patterns in `VPN_INTERFACES` in your config file. Use `netstat -nr` or `ip link show` to find your VPN interface names.

## Development

### Project Structure
```
terminalBanner/
├── install.sh              # Installation script
├── uninstall.sh            # Uninstallation script
├── banner.sh               # Main banner script
├── lib/
│   ├── detect.sh          # OS and service detection
│   ├── display.sh         # Banner formatting and display
│   └── system-info.sh     # System information gathering
├── config/
│   ├── banner.conf        # Main configuration file
│   └── services.conf      # Service definitions
└── README.md
```

### Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by [DietPi](https://dietpi.com/)'s terminal banner
- ASCII art support via [figlet](http://www.figlet.org/)
- WAN IP detection via [ipinfo.io](https://ipinfo.io/)

## Support

If you encounter any issues or have questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review your configuration files
3. Open an issue on GitHub with:
   - Your OS and shell type
   - Output of `bash -x ~/.config/terminal-banner/banner.sh`
   - Your configuration file (with sensitive info removed)

---

**Enjoy your customized terminal banner!** 🎉


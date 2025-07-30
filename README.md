# WIDIT - WSL is Docker is Tarballs

A WSL distro builder from your favourite docker images or a local dockerfile

## What is WIDIT?

WIDIT (WSL is Docker is Tarballs) is a tool that bridges the gap between Docker's rich ecosystem of container images and WSL's need for custom Linux distributions. It allows you to take any Docker image or Dockerfile and transform it into a fully functional WSL distribution with proper WSL integration, user management, and system configuration.

### The Problem

Creating custom WSL distributions traditionally requires:
- Manual rootfs creation and configuration
- Understanding WSL-specific requirements and limitations
- Setting up proper user management and permissions
- Configuring systemd services for WSL compatibility
- Managing the complex process of tarball creation and import

### The Solution

WIDIT automates this entire process by:
1. Taking your preferred Docker image or Dockerfile as a starting point
2. Layering WSL-specific configurations and optimizations
3. Setting up proper user management with an interactive first-run experience
4. Handling systemd service compatibility automatically
5. Producing a ready-to-import WSL distribution tarball with automatic import support

## Why This Approach?

### Pros of the WIDIT Approach

**🐳 Leverage Docker Ecosystem**: Start with any of the thousands of available Docker images (Ubuntu, Alpine, custom enterprise images, etc.) or your own Dockerfiles.

**⚡ Rapid Prototyping**: Quickly experiment with different base images and configurations without manual WSL setup.

**🔧 Automated WSL Integration**: Handles all the WSL-specific configuration automatically (wsl.conf, systemd compatibility, user management).

**🎯 Reproducible Builds**: Your WSL distributions are built from code, making them version-controllable and reproducible.

**🛠️ Developer-Friendly**: Uses familiar Docker tooling and concepts that developers already know.

**📦 Portable**: Generated tarballs can be shared, version-controlled, and deployed across teams.

**🚀 One-Click Import**: Optionally import distributions directly into WSL with proper Windows Terminal integration.

### Compared to Other Approaches

**vs. Manual WSL Distro Creation**
- ❌ Manual: Complex, error-prone, requires deep WSL knowledge
- ✅ WIDIT: Automated, handles edge cases, works with familiar Docker workflow

**vs. Using Existing WSL Distributions**
- ❌ Existing: Limited to what's available in Microsoft Store, hard to customize
- ✅ WIDIT: Any Docker image as starting point, full customization control

**vs. Docker Desktop WSL Integration**
- ❌ Docker Desktop: Runtime containers, not persistent development environments
- ✅ WIDIT: Creates actual WSL distributions for persistent development workflows

**vs. Custom Dockerfile + Manual Export**
- ❌ Manual Export: Missing WSL-specific configs, user management, systemd compatibility
- ✅ WIDIT: Proper WSL integration layer, handles all compatibility issues

**vs. LFS/BuildRoot Custom Linux**
- ❌ LFS/BuildRoot: Extremely complex, requires Linux distribution knowledge
- ✅ WIDIT: Start with proven base images, focus on your specific needs

## Testimonials

"The current design is actually quite elegant - it keeps the configuration simple while still allowing users to choose their own username through the interactive setup process." - Claude Sonnet 4.

## Pre-requisites

- Docker
- WSL2

## Usage

WIDIT can be run from any command prompt or terminal style through your WSL default distribution. The main entry point is the `creator.sh` script which handles building custom WSL distributions.

### From WSL Terminal

```bash
./creator.sh [OPTIONS]
```

### From PowerShell/Command Prompt

You can run the script directly from PowerShell or Command Prompt using WSL command execution:

```powershell
# From this directory:
# Run creator.sh through WSL
wsl ./creator.sh --base-image ubuntu:22.04
wsl ./creator.sh --dockerfile ./my-custom.dockerfile
wsl ./creator.sh --base-image alpine:latest --output my-alpine-wsl
```

### Options

The script accepts the following arguments:

- **--base-image IMAGE**: Use a Docker base image (e.g., ubuntu:22.04, alpine:latest)
- **--dockerfile PATH**: Build from a local Dockerfile
- **--output NAME**: Output name for the distribution tarball (default: widit-custom-distro)
- **--import**: Import the distribution into WSL after building
- **--install-path PATH**: WSL installation path (default: C:\WSL\{output-name})
- **--help**: Show help message

### Examples

**Build only (creates tarball for manual import):**
```bash
./creator.sh --base-image ubuntu:22.04
./creator.sh --dockerfile ./my-custom.dockerfile
./creator.sh --base-image alpine:latest --output my-alpine-wsl
```

**Build and auto-import to WSL:**
```bash
./creator.sh --base-image ubuntu:22.04 --import
./creator.sh --base-image debian:bullseye --output my-debian --import
./creator.sh --dockerfile ./custom.dockerfile --import --install-path C:\MyWSL\custom
```

**From PowerShell:**
```powershell
wsl ./creator.sh --base-image ubuntu:22.04 --output ubuntu-dev-env --import
wsl ./creator.sh --dockerfile ./enterprise.dockerfile --import
```

### What Happens When You Use --import

When you use the `--import` flag, WIDIT will:

1. **Build** the WSL distribution with all WSL-specific configurations
2. **Import** the distribution into WSL at the specified location
3. **Copy the icon** to the correct Windows filesystem location for Windows Terminal
4. **Configure Windows Terminal** - the distribution includes a pre-configured terminal profile that Windows Terminal will automatically discover

The imported distribution will appear in Windows Terminal with:
- Proper icon display
- Correct starting directory
- Pre-configured color scheme (Catppuccin Mocha)
- All WSL-specific optimizations

### Manual Import (without --import flag)

If you prefer to handle the import manually, the script will create a `.tar.gz` file:

```powershell
wsl --import MyDistroName C:\WSL\MyDistroName widit-custom-distro.tar.gz
```

After manual import, you can copy the icon and configure Windows Terminal yourself if desired.

## Developer details

### wsl-layer

Containing required configuration for a WSL distro that the system really appreciates.

Links: https://learn.microsoft.com/en-us/windows/wsl/build-custom-distro

### Disabling Problematic Systemd Units

Some systemd units are known to cause issues with WSL. By default, our system disables these units during setup. If you need to manually disable them, you can use the provided script:

```bash
/opt/widit/scripts/disable-services.sh
```

This script removes the symlinks for the following units, effectively disabling them without deleting the service files:

- `systemd-resolved.service`
- `systemd-networkd.service`
- `NetworkManager.service`
- `systemd-tmpfiles-setup.service`
- `systemd-tmpfiles-clean.service`
- `systemd-tmpfiles-clean.timer`
- `systemd-tmpfiles-setup-dev-early.service`
- `systemd-tmpfiles-setup-dev.service`
- `tmp.mount`

If you wish to override the default behavior and keep these units enabled, pass `DISABLE_PROBLEM_UNITS=false` to your Dockerfile environment before executing the WSL layering process.

Systemd recommendation from Microsoft: https://learn.microsoft.com/en-us/windows/wsl/build-custom-distro#systemd-recommendations
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
5. Producing a ready-to-import WSL distribution tarball

## Why This Approach?

### Pros of the WIDIT Approach

**🐳 Leverage Docker Ecosystem**: Start with any of the thousands of available Docker images (Ubuntu, Alpine, custom enterprise images, etc.) or your own Dockerfiles.

**⚡ Rapid Prototyping**: Quickly experiment with different base images and configurations without manual WSL setup.

**🔧 Automated WSL Integration**: Handles all the WSL-specific configuration automatically (wsl.conf, systemd compatibility, user management).

**🎯 Reproducible Builds**: Your WSL distributions are built from code, making them version-controllable and reproducible.

**🛠️ Developer-Friendly**: Uses familiar Docker tooling and concepts that developers already know.

**📦 Portable**: Generated tarballs can be shared, version-controlled, and deployed across teams.

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

- **Base Image**: Specify a Docker image to use as the base for your WSL distribution
  ```bash
  ./creator.sh --base-image ubuntu:22.04
  ./creator.sh --base-image debian:bullseye
  ```

- **Dockerfile**: Build from a local Dockerfile instead of using a base image
  ```bash
  ./creator.sh --dockerfile /path/to/Dockerfile
  ./creator.sh --dockerfile ./custom.dockerfile
  ```

- **Output Name**: Specify a custom name for the output tarball
  ```bash
  ./creator.sh --base-image ubuntu:22.04 --output my-ubuntu-wsl
  ```

### Examples

Create a WSL distribution from Ubuntu 22.04:
```bash
./creator.sh --base-image ubuntu:22.04
```

Build from a custom Dockerfile:
```bash
./creator.sh --dockerfile ./my-custom-distro.dockerfile
```

Create a custom Alpine-based distribution with a specific name:
```bash
./creator.sh --base-image alpine:latest --output my-alpine-dev
```

From PowerShell:
```powershell
wsl ./creator.sh --base-image ubuntu:22.04 --output ubuntu-dev-env
```

The script will handle the entire process of building the Docker image, layering the WSL-specific configurations, and creating a ready-to-import WSL distribution tarball.

### Importing the Created Distribution

After the script completes, you'll have a `.tar.gz` file that can be imported into WSL:

```powershell
wsl --import MyDistroName C:\WSL\MyDistroName widit-custom-distro.tar.gz
```

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

Systemd recommonedation from Microsoft: https://learn.microsoft.com/en-us/windows/wsl/build-custom-distro#systemd-recommendations
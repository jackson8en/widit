#!/bin/bash

# Check if DISABLE_PROBLEM_UNITS is set to false
if [ "${DISABLE_PROBLEM_UNITS,,}" == "false" ]; then
    echo "DISABLE_PROBLEM_UNITS is set to false. Skipping service disabling."
    exit 0
fi

# List of services to disable
services=(
    "systemd-resolved.service"
    "systemd-networkd.service"
    "NetworkManager.service"
    "systemd-tmpfiles-setup.service"
    "systemd-tmpfiles-clean.service"
    "systemd-tmpfiles-clean.timer"
    "systemd-tmpfiles-setup-dev-early.service"
    "systemd-tmpfiles-setup-dev.service"
    "tmp.mount"
)

# Iterate over each service and remove its symlink
for service in "${services[@]}"; do
    echo "Disabling $service..."
    find /etc/systemd/system -type l -name "$service" -exec rm -f {} +
done

echo "All specified services have been disabled."
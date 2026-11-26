#!/usr/bin/env bash
set -euo pipefail

VERSION="1.1.0"
BACKUP_ROOT="/var/lib/swift-linux/upgrade-backups"
VERSION_FILE="/etc/swift-linux/version"

log() {
    echo "[Swift Linux $VERSION] $*"
}

fail() {
    echo "[Swift Linux $VERSION] ERROR: $*" >&2
    exit 1
}

if [ "$(id -u)" -ne 0 ]; then
    fail "This installer must run as root."
fi

BUNDLE="${1:-}"

if [ -z "$BUNDLE" ]; then
    fail "Usage: install-1.1.0.sh /path/to/swift-linux-1.1.0.tar.zst"
fi

if [ ! -f "$BUNDLE" ]; then
    fail "Bundle not found: $BUNDLE"
fi

if ! command -v tar >/dev/null 2>&1; then
    fail "tar is required."
fi

if ! tar --help 2>/dev/null | grep -q zstd; then
    fail "This system's tar does not support zstd."
fi

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$BACKUP_ROOT/$TIMESTAMP-$VERSION"

mkdir -p "$BACKUP"

log "Starting Swift Linux $VERSION installation."
log "Creating backup: $BACKUP"

# Back up Swift Linux configuration and version information.
if [ -d /etc/swift-linux ]; then
    cp -a /etc/swift-linux "$BACKUP/"
fi

if [ -d /usr/share/swift-linux ]; then
    cp -a /usr/share/swift-linux "$BACKUP/"
fi

if [ -f /usr/bin/sps ]; then
    cp -a /usr/bin/sps "$BACKUP/"
fi

# Record the currently installed version.
if [ -f "$VERSION_FILE" ]; then
    cp -a "$VERSION_FILE" "$BACKUP/installed-version"
fi

# Verify the archive can actually be read before touching the system.
log "Checking update bundle..."

tar --zstd -tf "$BUNDLE" >/dev/null

log "Bundle verified."

# Extract into a temporary staging directory first.
STAGING="$(mktemp -d /tmp/swift-linux-1.1.0.XXXXXX)"

cleanup() {
    rm -rf "$STAGING"
}

trap cleanup EXIT

log "Extracting update..."

tar --zstd -xpf "$BUNDLE" -C "$STAGING"

# The bundle must contain a root filesystem.
if [ ! -d "$STAGING/rootfs" ]; then
    fail "Invalid Swift Linux bundle: missing rootfs/"
fi

log "Installing Swift Linux $VERSION..."

# Preserve permissions, ownership, links, ACLs and extended attributes.
rsync -aHAX \
    "$STAGING/rootfs/" \
    /

# Update the installed version only after the system files were installed.
mkdir -p "$(dirname "$VERSION_FILE")"

printf '%s\n' "$VERSION" > "$VERSION_FILE"

# Record successful installation.
printf '%s\n' "$VERSION" > "$BACKUP/previous-install-success"

log "Swift Linux $VERSION installed successfully."
log "Backup saved at: $BACKUP"
log "Installation complete."

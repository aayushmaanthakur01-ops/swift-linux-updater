# Swift Linux Updates

Official update repository for **Swift Linux**.

This repository is used by the **SPS Upgrade Center** to discover, verify, install, upgrade, and roll back Swift Linux releases.

## Repository Layout

```text
stable/
├── versions.json
├── 1.0.0/
│   └── manifest.json
└── 1.1.0/
    └── manifest.json
```

## Stable Channel

The `stable` channel contains officially published Swift Linux releases.

### Swift Linux 1.1.0

Swift Linux 1.1.0 is the first major post-1.0 release.

Planned highlights:

- SPS 1.1
- SPS Upgrade Center
- Swift Linux system upgrades
- Rollback support
- SHA256 update verification
- Pre-upgrade backups
- Improved SPS Doctor
- Installer improvements

## How Updates Work

The SPS Upgrade Center checks:

```text
stable/versions.json
```

It then retrieves the release manifest for the selected version.

Before installing an update, the Upgrade Center will:

1. Check the selected release.
2. Download the update bundle.
3. Verify its SHA256 checksum.
4. Create a backup.
5. Run the Swift Linux release installer.
6. Update the installed Swift Linux version.
7. Report the result in the Upgrade Center.

## Release Bundles

Release bundles will be published alongside their release manifests.

Example:

```text
stable/1.1.0/
├── manifest.json
└── swift-linux-1.1.0.tar.zst
```

The bundle contains the files required to update Swift Linux.

## Rollbacks

Older stable releases remain available so the Upgrade Center can provide rollback support when a compatible backup or release bundle is available.

## Security

Release bundles must have a SHA256 checksum recorded in their manifest.

The Upgrade Center verifies the checksum before installing an update.

## Swift Linux

Swift Linux is an Arch-based Linux distribution focused on speed, flexibility, and a simple package and system management experience through SPS.

**Swift Linux — fast, flexible, and yours.**

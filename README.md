# Beeper Flatpak

This repository contains the Flatpak packaging for Beeper, the ultimate chat app that brings all your messaging services into one place.

## Quick Start

### One-Command Update and Install
```bash
just update-and-install
```

This single command will:
1. 🔄 Fetch the latest Beeper version from the API
2. 📝 Update the manifest with new URL, SHA256, and size
3. 🔨 Build the Flatpak
4. 📦 Export to local repository
5. ⬇️ Install or update the Flatpak

### Individual Commands

#### Update to Latest Version
```bash
just update-to-latest
```
Automatically fetches the latest Beeper version and updates the manifest.

#### Build Flatpak
```bash
just build-flatpak
```
Builds the Flatpak from the current manifest.

#### Install from Local Repository
```bash
just install-flatpak
```
Installs the Flatpak from the local repository (works with extra-data apps like Beeper).

#### Create Bundle
```bash
just build-flatpak-bundle
```
Creates a `.flatpak` bundle file (note: bundles don't work well with extra-data apps for installation).

#### Update Existing Installation
```bash
just update-flatpak
```
Updates an already installed Flatpak with the latest build.

## Manual Process

If you prefer to update manually:

1. **Get the latest version URL:**
   ```bash
   curl -s -I "https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop"
   ```

2. **Update the manifest** (`com.beeper.beepertexts.yml`) with:
   - New URL
   - Updated SHA256 checksum
   - Updated file size

3. **Build and install:**
   ```bash
   just build-flatpak
   flatpak build-export repo .flatpak-builder/build-dir
   flatpak --user install repo com.beeper.beepertexts
   ```

## Files Structure

- `com.beeper.beepertexts.yml` - Main Flatpak manifest
- `com.beeper.beepertexts.metainfo.xml` - AppStream metadata
- `com.beeper.beepertexts.desktop` - Desktop file
- `com.beeper.beepertexts.png` - Application icon
- `apply_extra.sh` - Script to extract the AppImage
- `update-to-latest.sh` - Automated update script
- `Justfile` - Build automation recipes
- `flathub.json` - Flathub configuration

## Troubleshooting

### Build Fails with Namespace Error
If you see `bwrap: No permissions to creating new namespace`, the build script automatically removes the `--install` flag to avoid this issue. Use `just install-flatpak` instead.

### AppStream Metadata Errors
- Ensure `metadata_license` is set to `CC0-1.0` (not `Proprietary`)
- Check that XML is well-formed with no duplicate closing tags

### Extra Data Missing
This app uses `extra-data` (AppImage download), so:
- Bundles may not work for installation
- Use the local repository method: `flatpak --user install repo com.beeper.beepertexts`

## Development

The build process:
1. Downloads and extracts the Beeper AppImage using `unappimage`
2. Creates a wrapper script that launches Beeper with proper Flatpak integration
3. Installs desktop files, icons, and metadata

### Testing Changes
```bash
# Build without installing
just build-flatpak

# Test the built app
flatpak run --devel com.beeper.beepertexts
```

## API Integration

The update script uses Beeper's API endpoint:
```
https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop
```

This endpoint redirects to the latest AppImage download URL, which the script parses to get version information.

## Contributing

1. Test your changes with `just build-flatpak`
2. Ensure the app runs correctly
3. Update version information as needed
4. Submit pull requests with clear descriptions

## License

This packaging is provided under the same terms as the Flatpak ecosystem. Beeper itself is proprietary software by Automattic Inc.

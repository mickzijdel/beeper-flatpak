# These are just convenience scripts, NOT a build system!

appid := env("APPID", "com.beeper.beepertexts")
manifest := appid + ".yml"
branch := env("BRANCH", "stable")
just := just_executable()



build-flatpak $manifest=manifest $branch=branch:
    #!/usr/bin/env bash
    set -xeuo pipefail
    flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    FLATPAK_BUILDER_DIR=$(realpath ".flatpak-builder")
    BUILDER_ARGS+=(--default-branch="${branch}")
    BUILDER_ARGS+=(--state-dir="${FLATPAK_BUILDER_DIR}/flatpak-builder")
    BUILDER_ARGS+=("--user")
    BUILDER_ARGS+=("--ccache")
    BUILDER_ARGS+=("--force-clean")
    BUILDER_ARGS+=("--disable-rofiles-fuse")
    BUILDER_ARGS+=("${FLATPAK_BUILDER_DIR}/build-dir")
    BUILDER_ARGS+=("${manifest}")

    if which flatpak-builder &>/dev/null ; then
        flatpak-builder "${BUILDER_ARGS[@]}"
    else
        flatpak run org.flatpak.Builder "${BUILDER_ARGS[@]}"
    fi

build-flatpak-bundle $appid=appid:
    #!/usr/bin/env bash
    set -xeuo pipefail
    flatpak build-export repo .flatpak-builder/build-dir
    flatpak build-bundle repo "${appid}".flatpak "${appid}"

install-flatpak $appid=appid:
    #!/usr/bin/env bash
    set -xeuo pipefail
    flatpak build-export repo .flatpak-builder/build-dir
    flatpak --user install repo "${appid}"

update-flatpak $appid=appid:
    #!/usr/bin/env bash
    set -xeuo pipefail
    flatpak build-export repo .flatpak-builder/build-dir
    flatpak --user update "${appid}"

update-to-latest:
    #!/usr/bin/env bash
    ./update-to-latest.sh

# Complete workflow: update manifest, build, and install latest version
update-and-install $appid=appid:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🔄 Updating to latest Beeper version..."
    ./update-to-latest.sh
    echo "🔨 Building Flatpak..."
    just build-flatpak
    echo "📦 Exporting to repo..."
    flatpak build-export repo .flatpak-builder/build-dir
    echo "⬇️ Installing/updating Flatpak..."
    if flatpak --user list | grep -q "${appid}"; then
        echo "Updating existing installation..."
        flatpak --user update "${appid}" || true
    else
        echo "Installing for the first time..."
        flatpak --user install repo "${appid}"
    fi
    echo "✅ Done! Beeper has been updated and installed."

[private]
default:
    @{{ just }} --list

# Check just Syntax
[group('just')]
check:
    #!/usr/bin/bash
    find . -type f -name "*.just" | while read -r file; do
    	echo "Checking syntax: $file"
    	{{ just }} --unstable --fmt --check -f $file
    done
    echo "Checking syntax: Justfile"
    {{ just }} --unstable --fmt --check -f Justfile

# Fix {{ just }} Syntax
[group('{{ just }}')]
fix:
    #!/usr/bin/bash
    find . -type f -name "*.just" | while read -r file; do
    	echo "Checking syntax: $file"
    	{{ just }} --unstable --fmt -f $file
    done
    echo "Checking syntax: Justfile"
    {{ just }} --unstable --fmt -f Justfile || { exit 1; }

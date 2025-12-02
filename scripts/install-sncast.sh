#!/usr/bin/env bash
set -euo pipefail

# Attempt to install 'sncast' using several common strategies.
# This script tries a set of candidate GitHub release URLs and common
# fallbacks. It is intentionally permissive: it exits 0 if sncast
# becomes available, non-zero otherwise.

TMPDIR=$(mktemp -d)
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

echo "Checking if sncast is already installed..."
if command -v sncast >/dev/null 2>&1; then
  echo "sncast found at $(command -v sncast)"
  exit 0
fi

echo "sncast not found. Trying to download prebuilt releases from candidate repos..."

candidate_repos=(
  "naiam-studio/sncast"
  "naim-studio/sncast"
  "Ztarknet/sncast"
  "ztarknet/sncast"
  "starknet-foundry/sncast"
  "sncast/sncast"
)

asset_patterns=(
  "sncast-linux-x86_64.tar.gz"
  "sncast-x86_64-unknown-linux-gnu.tar.gz"
  "sncast-linux-amd64.tar.gz"
  "sncast-linux-amd64"
  "sncast.tar.gz"
)

for repo in "${candidate_repos[@]}"; do
  for asset in "${asset_patterns[@]}"; do
    url="https://github.com/${repo}/releases/latest/download/${asset}"
    echo "Trying $url"
    set +e
    curl -fSL "$url" -o "$TMPDIR/$asset"
    rc=$?
    set -e
    if [ $rc -eq 0 ]; then
      echo "Downloaded $asset from $repo"
      # try to untar or move depending on file
      if file "$TMPDIR/$asset" | grep -q 'gzip compressed'; then
        tar -xzf "$TMPDIR/$asset" -C "$TMPDIR"
      else
        chmod +x "$TMPDIR/$asset"
        mv "$TMPDIR/$asset" "$TMPDIR/sncast"
      fi
      if [ -f "$TMPDIR/sncast" ]; then
        sudo mv "$TMPDIR/sncast" /usr/local/bin/sncast
        sudo chmod +x /usr/local/bin/sncast
        echo "Installed sncast to /usr/local/bin/sncast"
        command -v sncast >/dev/null 2>&1 && exit 0
      else
        # try to find a binary extracted
        binpath=$(find "$TMPDIR" -type f -name 'sncast' -perm /111 | head -n1 || true)
        if [ -n "$binpath" ]; then
          sudo mv "$binpath" /usr/local/bin/sncast
          sudo chmod +x /usr/local/bin/sncast
          echo "Installed sncast to /usr/local/bin/sncast"
          command -v sncast >/dev/null 2>&1 && exit 0
        fi
      fi
    fi
  done
done

echo "Prebuilt release not found or installation failed. Trying other fallbacks..."

# Try common installer URLs (placeholder examples)
if command -v apt >/dev/null 2>&1; then
  echo "No apt package known for sncast. Skipping apt install."
fi

# Final fallback: show helpful message and exit non-zero
echo "Automatic installation failed. Please install 'sncast' manually."
echo "Suggested steps (pick one):"
echo "  - Check the project's GitHub releases and download a Linux binary/tarball and move to /usr/local/bin"
echo "  - If the project provides an 'asdf' plugin, install via asdf: 'asdf plugin-add sncast <url> && asdf install sncast <version>'"
echo "After installation, re-run: make account-create"

exit 2

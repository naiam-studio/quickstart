#!/usr/bin/env bash
set -euo pipefail

# Quick setup script: installs all required tools in sequence
# Run this once to bootstrap the environment.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "================================"
echo "Oz Kit - Automatic Setup"
echo "================================"
echo ""
echo "This script will install:"
echo "  - Rust & Cargo"
echo "  - Scarb"
echo "  - Noir CLI"
echo "  - Barretenberg (bb)"
echo "  - JavaScript dependencies (in app/)"
echo ""
echo "Press Ctrl+C to cancel, or Enter to continue..."
read -r

# 1. Rust
echo ""
echo "[1/5] Installing Rust & Cargo..."
if ! command -v cargo >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | RUSTUP_INIT_SKIP_PATH_CHECK=yes sh -s -- -y
  if [ -f /usr/local/cargo/env ]; then
    . /usr/local/cargo/env
  elif [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
  fi
else
  echo "Cargo already installed."
fi

# 2. Scarb
echo ""
echo "[2/5] Installing Scarb..."
"$REPO_DIR/scripts/install-scarb.sh" || echo "Warning: Scarb installation failed."

# 3. Noir
echo ""
echo "[3/5] Installing Noir CLI..."
"$REPO_DIR/scripts/install-noir.sh" || echo "Warning: Noir installation failed."

# 4. Barretenberg
echo ""
echo "[4/5] Installing Barretenberg (bb)..."
"$REPO_DIR/scripts/install-barretenberg.sh" || echo "Warning: Barretenberg installation failed."

# 5. JavaScript deps
echo ""
echo "[5/5] Installing JavaScript dependencies..."
cd "$REPO_DIR/app"
npm install --legacy-peer-deps || echo "Warning: npm install failed."
cd "$REPO_DIR"

echo ""
echo "================================"
echo "Setup complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "  1. Install sncast: make install-sncast"
echo "  2. Create account:  make account-create"
echo "  3. Top up account:  make account-topup (via faucet first)"
echo "  4. Deploy account:  make account-deploy"
echo "  5. Check balance:   make account-balance"
echo ""
echo "Then proceed to 'Deploy Application' section in README.md"

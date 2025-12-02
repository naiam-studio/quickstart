#!/usr/bin/env bash
set -euo pipefail

# Quick setup script: installs all required tools in sequence
# Run this once to bootstrap the environment.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "================================"
echo "Oz Kit - Automatic Setup"
echo "================================"
echo ""
echo "This script will install:"
echo "  - System dependencies (libc++1)"
echo "  - Rust & Cargo"
echo "  - Scarb"
echo "  - Noir CLI"
echo "  - Barretenberg (bb)"
echo "  - Garaga (Python CLI)"
echo "  - JavaScript dependencies (in app/ and admin/)"
echo ""
echo "Press Ctrl+C to cancel, or Enter to continue..."
read -r

# 0. System dependencies
echo ""
echo "[0/7] Installing system dependencies..."
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update >/dev/null 2>&1 || echo "Warning: apt-get update failed."
  sudo apt-get install -y libc++1 >/dev/null 2>&1 || echo "Warning: libc++1 installation failed."
  echo "System dependencies installed (libc++1 for Barretenberg)."
else
  echo "Warning: apt-get not available. Skipping system dependencies."
fi

# 1. Rust
echo ""
echo "[1/7] Installing Rust & Cargo..."
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
echo "[2/7] Installing Scarb..."
"$SCRIPT_DIR/install-scarb.sh" || echo "Warning: Scarb installation failed."

# 3. Noir
echo ""
echo "[3/7] Installing Noir CLI..."
"$SCRIPT_DIR/install-noir.sh" || echo "Warning: Noir installation failed."

# 4. Barretenberg
echo ""
echo "[4/7] Installing Barretenberg (bb)..."
"$SCRIPT_DIR/install-barretenberg.sh" || echo "Warning: Barretenberg installation failed."

# Try installing bb via bbup if available but bb missing
if ! command -v bb >/dev/null 2>&1 && command -v bbup >/dev/null 2>&1; then
  echo "bb not found but bbup is available. Installing bb v0.67.0 via bbup..."
  # shellcheck disable=SC1090
  source "$HOME/.bashrc" 2>/dev/null || true
  bbup --version 0.67.0 || echo "Warning: bbup install failed."
fi

# 5. Garaga (Python CLI)
echo ""
echo "[5/7] Installing Garaga (Python CLI)..."

# Ensure ~/.local/bin is in PATH for pip --user installs
export PATH="$HOME/.local/bin:$PATH"

if ! command -v garaga >/dev/null 2>&1; then
  if command -v pip3 >/dev/null 2>&1; then
    pip3 install --user garaga==0.15.5 || echo "Warning: pip3 install garaga failed."
  elif command -v pip >/dev/null 2>&1; then
    pip install --user garaga==0.15.5 || echo "Warning: pip install garaga failed."
  else
    echo "Warning: pip/pip3 not found. Skipping Garaga installation."
  fi
  
  # Verify installation
  if command -v garaga >/dev/null 2>&1; then
    echo "Garaga installed successfully at $(which garaga)"
  else
    echo "Warning: Garaga installed but not in PATH. Add ~/.local/bin to your PATH."
    echo "Run: export PATH=\"\$HOME/.local/bin:\$PATH\""
  fi
else
  echo "Garaga already installed at $(which garaga)"
fi

# 6. JavaScript deps (app/)
echo ""
echo "[6/7] Installing JavaScript dependencies (app/)..."
cd "$REPO_DIR/app"
npm install --legacy-peer-deps || echo "Warning: npm install (app/) failed."
cd "$REPO_DIR"

# 7. JavaScript deps (admin/)
echo ""
echo "[7/7] Installing JavaScript dependencies (admin/)..."
cd "$REPO_DIR/admin"
npm install || echo "Warning: npm install (admin/) failed."
cd "$REPO_DIR"

echo ""
echo "================================"
echo "Setup complete!"
echo "================================"
echo ""
echo "IMPORTANT: Add user bin to PATH if not already present:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo "  (Add this line to ~/.bashrc or ~/.zshrc for persistence)"
echo ""
echo "Next steps:"
echo "  1. Install sncast: make install-sncast"
echo "  2. Create account:  make account-create"
echo "  3. Top up account:  make account-topup (via faucet first)"
echo "  4. Deploy account:  make account-deploy"
echo "  5. Check balance:   make account-balance"
echo ""
echo "Then proceed to 'Deploy Application' section in README.md"

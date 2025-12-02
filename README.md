
![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?template_repository=naiam-studio/Oz-Kit-Ztarknet-Noir-Garaga)

# Oz Kit - Noir-Garaga-Ztarknet Kit


Step-by-step template and tutorial to deploy a privacy (ZK) app on Ztarknet using Noir, Garaga, and Starknet. Includes Noir circuit integration, Cairo contract generation with Garaga, and scripts for deployment/interaction on the network.

---

## 🚀 Use this as a Template CodeSpace

You can use this template as a starting point for your own ZK dApps on Starknet. Fork, clone, or open as a Codespace and start building!

---

## ⚡ Quick Start (30 minutes)

The fastest way to get everything running. Choose one:

Option A — Open in Codespaces (recommended):

```bash
# Open directly in GitHub Codespaces (click the link)
# https://github.com/codespaces/new?template_repository=naiam-studio/Oz-Kit-Ztarknet-Noir-Garaga
```

Option B — Clone locally:

```bash
# 1. Clone the repository
git clone https://github.com/naiam-studio/Oz-Kit-Ztarknet-Noir-Garaga.git
cd Oz-Kit-Ztarknet-Noir-Garaga

# 2. Run automated setup (installs Rust, Scarb, Noir, bb, and npm deps)
./scripts/setup.sh

# 3. Install sncast and create account
make install-sncast
make account-create

# 4. Top up account via faucet at https://faucet.ztarknet.cash/ (paste the address above)

# 5. Install admin dependencies (required for top-up)
cd admin && npm install && cd ..

# 6. Deploy account
make account-topup
make account-deploy

# 6. Create a circuit and prove it
cd circuit
nargo check
nargo execute witness

# 7. Generate proof and verifier
bb prove --scheme ultra_honk --zk --oracle_hash starknet -b ./target/circuit.json -w ./target/witness.gz -o ./target
bb write_vk --scheme ultra_honk --oracle_hash starknet -b ./target/circuit.json -o ./target
cd ..

# 8. Generate verifier contract and deploy
garaga gen --system ultra_starknet_zk_honk --vk ./circuit/target/vk --project-name verifier
cd verifier && scarb build && cd ..

# 10. Run the frontend
make artifacts
cd app && npm install --legacy-peer-deps && npm run dev
```

---

## ⚡️ Reproducible Compatible Environment (Tested Versions)

> **IMPORTANT:** These versions have been verified as compatible for the Noir → Garaga → Cairo → Ztarknet flow.

### Recommended Versions

- **Noir CLI:** 1.0.0-beta.1
- **Barretenberg (bb):** 0.67.0
- **Garaga:** 0.15.5
- **Scarb:** 2.9.2
- **garaga (JS):** 0.15.5
- **@noir-lang/noir_js:** 1.0.0-beta.1
- **@aztec/bb.js:** 0.67.0

> **NOTE:** The entire pipeline (circuit, proofs, vk, verifier, calldata, and contracts) is configured to use the `ultra_starknet_zk_honk` system. Do not mix with other systems (like `ultra_keccak_honk`) unless you adapt the whole flow and contracts.

### Installation Steps (Linux/Ubuntu - Tested)

**Automated Setup (Recommended)**

Run the all-in-one setup script to install all tools at once:

```bash
./scripts/setup.sh
```

This will install Rust, Scarb, Noir, Barretenberg, and JavaScript dependencies in sequence.

**Manual Installation (Step-by-Step)**

If you prefer to install tools individually, follow the steps below.

#### 1. Install Rust and Cargo

```bash
# Install rustup (recommended). If a system Rust is already present
# and you want rustup to install alongside it, set
# RUSTUP_INIT_SKIP_PATH_CHECK=yes to skip the PATH check.
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | RUSTUP_INIT_SKIP_PATH_CHECK=yes sh -s -- -y

# Source the correct cargo environment file. Some environments (CI
# images or preinstalled Rust) place cargo under /usr/local, others
# under the user home. This checks both locations.
if [ -f /usr/local/cargo/env ]; then
  . /usr/local/cargo/env
elif [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
else
  echo "Warning: cargo env file not found. Restart your shell or add Cargo's bin to PATH manually."
fi

# After installation you may need to restart your shell for PATH to update.
```

#### 2. Install Scarb 2.9.2

```bash
# Use the automated installer
make install-scarb

# Or run the script directly
./scripts/install-scarb.sh

# Verify installation
scarb --version  # Should output: scarb 2.9.2
```

#### 3. Install Noir CLI 1.0.0-beta.1

```bash
# Use the automated installer
make install-noir

# Or run the script directly
./scripts/install-noir.sh

# Verify installation
nargo --version  # Should output: nargo version = 1.0.0-beta.1
```

#### 4. Install Barretenberg (bb) 0.67.0

```bash
# Use the automated installer shipped with this repo
make install-barretenberg

# If that fails, try the official Aztec installer
curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/master/barretenberg/cpp/installation/install | bash

# Verify installation
bb --version  # Should output: 0.67.0
```

#### 6. Install Garaga 0.15.5 (Python CLI)

Garaga es la herramienta que genera el contrato verificador para Starknet y serializa la prueba como calldata.

```bash
# Install via pip (recommended version)
pip install garaga==0.15.5

# Verify installation
garaga --version  # Should output: garaga 0.15.5
```

Si prefieres instalar la última versión disponible:

```bash
pip install garaga
```

Nota: asegúrate de que tu entorno Python esté disponible en PATH (por ejemplo, usando `python3`/`pip3`) y que el binario `garaga` quede accesible en tu shell.

#### 5. Install JavaScript Dependencies in `app`

```bash
# Navigate to the app directory
cd /workspaces/quickstart/app

# Install dependencies with legacy peer deps flag (required for vite compatibility)
npm install --legacy-peer-deps

# Verify key packages are installed
npm list @noir-lang/noir_js garaga @aztec/bb.js
```

### Quick Version Check

After installation, verify all tools are available and at the correct versions:

```bash
scarb --version      # Expected: scarb 2.9.2
nargo --version      # Expected: nargo version = 1.0.0-beta.1
bb --version         # Expected: 0.67.0
```

---

## Set Up the Environment

### Installation

Install Starknet development suite (recommended via asdf):
- **Scarb:** https://docs.swmansion.com/scarb/download.html#install-via-asdf
- **Starknet Foundry:** https://foundry-rs.github.io/starknet-foundry/getting-started/installation.html

### Create and Deploy Your Account

The repository provides Makefile targets to create an account, deploy it and check the balance. These targets rely on the `sncast` CLI being installed and available on your `PATH`.

1) Install `sncast` (required)

```bash
# sncast is typically available in GitHub Codespaces and dev containers.
# If not installed, use the automated installer:
make install-sncast

# Or run the script directly:
./scripts/install-sncast.sh

# Verify installation
sncast --help
```

2) Create the account

After `sncast` is installed, create the account configured in this repo:

```bash
make account-create
```

3) Top up the account via the faucet

Visit the Ztarknet faucet at https://faucet.ztarknet.cash/ and send tokens to the account address produced by `make account-create`. You can also use the helper `account-topup` target which reads the address from `sncast` and calls the `admin/topup` script:

```bash
make account-topup
```

4) Deploy the account contract

```bash
make account-deploy
```

5) Check the balance

```bash
make account-balance
```

**Troubleshooting**

- If `make account-create` prints `sncast: No such file or directory`, ensure `sncast` is on your `PATH` and executable.
- If you cannot find an official prebuilt binary, the recommended fallback is to build `sncast` from its upstream source via `cargo build --release` and move the produced binary to `/usr/local/bin`.

---

## Deploy Application

### Create and Prove a Circuit

Start by creating a new Noir project:

```bash
nargo new circuit
cd circuit
nargo check
```

Fill the `Prover.toml` file with the inputs:

```toml
x = "1"
y = "2"
```

Execute the circuit to generate a witness:

```bash
nargo execute witness
```

Prove the circuit using Barretenberg with the `ultra_starknet_zk_honk` system:

```bash
bb prove --scheme ultra_honk --zk --oracle_hash starknet -b ./target/circuit.json -w ./target/witness.gz -o ./target/proof
```

Generate a verifying key:

```bash
bb write_vk --scheme ultra_honk --oracle_hash starknet -b ./target/circuit.json -o ./target/vk
```

### Generate Verifier Contract

Let Garaga automatically generate a Scarb project for you:

```bash
garaga gen --system ultra_starknet_zk_honk --vk ./circuit/target/vk --project-name verifier
```

Now build the contract:

```bash
scarb build
```

### Deploy Verifier Contract

First, declare the contract ("upload its code hash to the network"):

```bash
# In the root dir
cd verifier && sncast declare --contract-name UltraStarknetZKHonkVerifier
```

Then instantiate it (change class-hash according to the output from the previous step):

```bash
# In the root dir
sncast invoke \
  --contract-address 0x041a78e741e5af2fec34b695679bc6891742439f7afb8484ecd7766661ad02bf \
  --function "deployContract" \
  --calldata 0x3575239fa10a4e2bacbf0e2105f8d86473aa19d21441b39675be7fbb5924adf 0x0 0x0 0x0
```

Check the transaction in the [explorer](https://explorer-zstarknet.d.karnot.xyz/) to see the deployed contract address (see events).

**What just happened:**
- We asked the universal deployer contract (UDC v1) to deploy the Garaga verifier
- We passed the verifier class hash as the first argument and set the rest to zeros (no constructor parameters)

### Verify the Proof on Ztarknet

Serialize the Noir proof as contract calldata:

```bash
garaga calldata --system ultra_starknet_zk_honk --proof circuit/target/proof --vk circuit/target/vk --public-inputs circuit/target/public_inputs > calldata.txt
```

Call the verifier contract (without creating a transaction):

```bash
sncast call \
    --contract-address 0x02048def58e122c910f80619ebab076b0ef5513550d38afdfdf2d8a1710fa7c6 \
    --function "verify_ultra_starknet_zk_honk_proof" \
    --calldata $(cat calldata.txt)
```

Invoke the verifier contract to create a transaction:

```bash
sncast invoke \
  --contract-address 0x02048def58e122c910f80619ebab076b0ef5513550d38afdfdf2d8a1710fa7c6 \
  --function "verify_ultra_starknet_zk_honk_proof" \
  --calldata $(cat calldata.txt)
```

Check the transaction in the [explorer](https://explorer-zstarknet.d.karnot.xyz/).

---

## Add a Simple Frontend

A single page app that generates a proof and calls a previously deployed contract.

First, copy all necessary artifacts to the app folder:

```bash
make artifacts
```

Install bun and JS dependencies, then run the app:

```bash
cd app
curl -fsSL https://bun.sh/install | bash
bun install
bun run dev
```

---

## Project Structure

```
.
├── circuit/                 # Noir ZK circuit definitions
│   ├── Nargo.toml          # Noir project manifest
│   ├── Prover.toml         # Proof inputs
│   └── src/
├── verifier/               # Cairo verifier contract (auto-generated by Garaga)
│   ├── Scarb.toml          # Scarb project manifest
│   └── src/
├── app/                    # React + TypeScript frontend
│   ├── package.json        # Frontend dependencies
│   ├── src/
│   └── assets/
│       ├── circuit.json    # Compiled circuit
│       ├── verifier.json   # Verifier contract
│       └── vk.bin          # Verifying key
├── admin/                  # Admin scripts
│   ├── package.json        # Admin dependencies
│   └── topup.js            # Account top-up script
└── Makefile               # Common tasks
```

---

## Troubleshooting

### macOS Issues

Barretenberg and sncast have known issues on macOS:
- **Barretenberg** crashes due to dylib linking issues
- **sncast** fails due to SystemConfiguration bugs

**Solution:** Use a Linux environment or GitHub Codespaces.

### Large Calldata

Garaga-generated calldata can be large (50-100+ KB). This is normal and doesn't affect functionality, but keep gas usage in mind when verifying proofs on-chain.

### Environment Setup

If you encounter missing libraries or dependency issues:

```bash
# Re-install system dependencies
sudo apt-get update && sudo apt-get install -y libc++1

# Re-install JavaScript dependencies
cd app && npm install --legacy-peer-deps
```

---

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](../../issues) or submit a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Get Help

Something went wrong? Ask us in the [Zypherpunk hackathon chat](https://t.me/+euCua6eocTc1NmM1).

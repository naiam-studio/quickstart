
# [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?template_repository=Ztarknet/quickstart)

# Oz Kit - Noir-Garaga-Ztarknet Kit

Step-by-step template and tutorial to deploy a privacy (ZK) app on Ztarknet using Noir, Garaga, and Starknet. Includes Noir circuit integration, Cairo contract generation with Garaga, and scripts for deployment/interaction on the network.


---

## 🚀 Use this as a Template CodeSpace

Click the **"Open in GitHub Codespaces"** badge above or use the GitHub UI to create a new Codespace from this repository. The devcontainer will set up all required tools and dependencies automatically.

You can use this template as a starting point for your own ZK dApps on Starknet. Fork, clone, or open as a Codespace and start building!

---
## Contributing

Contributions, issues and feature requests are welcome! Feel free to check [issues page](../../issues) or submit a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

> **NOTE:** The entire pipeline (circuit, proofs, vk, verifier, calldata, and contracts) is configured to use the `ultra_starknet_zk_honk` system. Do not mix with other systems (like `ultra_keccak_honk`) unless you adapt the whole flow and contracts.

## ⚡️ Reproducible compatible environment (tested versions)

> **IMPORTANT:** These versions have been tested as compatible for the Noir → Garaga → Cairo → Ztarknet flow.

# Oz Kit - Noir-Garaga-Ztarknet Kit

Template y tutorial paso a paso para desplegar una app de privacidad (ZK) en Ztarknet usando Noir, Garaga y Starknet. Incluye integración de circuitos Noir, generación de contratos Cairo con Garaga y scripts para despliegue/interacción en la red.

---

> **NOTA:** Todo el pipeline (circuito, pruebas, vk, verificador, calldata y contratos) está configurado para usar el sistema `ultra_starknet_zk_honk`. No mezcles con otros sistemas (como `ultra_keccak_honk`) salvo que adaptes todo el flujo y los contratos.

## ⚡️ Reproducir entorno compatible (versiones probadas)

> **IMPORTANTE:** Estas versiones han sido verificadas como compatibles para el flujo Noir → Garaga → Cairo → Ztarknet.

### Versiones recomendadas
```



# Oz Kit - Noir-Garaga-Ztarknet Kit

Step-by-step template and tutorial to deploy a privacy (ZK) app on Ztarknet using Noir, Garaga, and Starknet. Includes Noir circuit integration, Cairo contract generation with Garaga, and scripts for deployment/interaction on the network.

---

> **NOTE:** The entire pipeline (circuit, proofs, vk, verifier, calldata, and contracts) is configured to use the `ultra_starknet_zk_honk` system. Do not mix with other systems (like `ultra_keccak_honk`) unless you adapt the whole flow and contracts.

## ⚡️ Reproducible compatible environment (tested versions)

> **IMPORTANT:** These versions have been tested as compatible for the Noir → Garaga → Cairo → Ztarknet flow.

### Recommended versions
- Noir CLI: **1.0.0-beta.1**
- Barretenberg (bb): **0.67.0**
- Garaga: **0.15.5**
- Scarb: **2.9.2**
- garaga (JS): **0.15.5**
- @noir-lang/noir_js: **1.0.0-beta.1**
- @aztec/bb.js: **0.67.0**

### Main tool installation

```bash
# Install Scarb 2.9.2
cargo install --locked --version 2.9.2 scarb

# Install Noir CLI 1.0.0-beta.1
cargo install --locked --version 1.0.0-beta.1 noir
# Or follow the official Noir installer if the method changes

# Install Barretenberg (bb) 0.67.0
# Download the binary from the official release and place it in your PATH
# Example (adjust the URL to the real release):

Install Starknet development suite (recommended way is via asdf):
sudo mv bb /usr/local/bin/
- Scarb https://docs.swmansion.com/scarb/download.html#install-via-asdf
```
### JS/TS dependencies in `app`

```bash
cd app
npm ci  # or bun install if you use bun
# If you need to reinstall exact dependencies:
- Starknet Foundry https://foundry-rs.github.io/starknet-foundry/getting-started/installation.html
```
```

### Build and test

```bash
# Cairo verifier
cd verifier
scarb build

# App frontend
cd ../app
npm run dev
```

---

## Set up the environment

### Installation

Install Starknet development suite (recommended way is via asdf):
- Scarb https://docs.swmansion.com/scarb/download.html#install-via-asdf
- Starknet Foundry https://foundry-rs.github.io/starknet-foundry/getting-started/installation.html

### Create and deploy your account

```bash
make account-create
```

Go to the [faucet](https://faucet.ztarknet.cash/) and top up your account address.

```bash
make account-deploy
```

Make sure you received the funds:

```bash
make account-balance
```

## Deploy application

### Installation

Install Noir development toolchain:

```bash
make install-barretenberg
```

Install Garaga SDK & CLI:

```bash

> [!NOTE]
> Python 3.10 is required to install Garaga.
> Use `pyenv` to manage your Python versions.

### Create and prove a circuit

Start by creating a new Noir project:

```bash
nargo new circuit
cd circuit
nargo check
```

Fill the `Prover.toml` file with the inputs:

```toml
x = "1"

```

Execute the circuit to generate a witness:

```bash
nargo execute witness
```

Prove the circuit:

```bash
bb prove --scheme ultra_honk --zk --oracle_hash starknet -b ./target/circuit.json -w ./target/witness.gz -o ./target
```

Generate a verifying key:

```bash
bb write_vk --scheme ultra_honk --oracle_hash starknet -b ./target/circuit.json -o ./target
```

### Generate and verifier contract

Let Garaga automatically generate a Scarb project for you:

```bash
garaga gen --system ultra_starknet_zk_honk --vk ./circuit/target/vk --project-name verifier
```

Now you can build the contract:

```bash
scarb build
```

### Deploy verifier contract

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

What just happened:
- We asked the universal deployer contract (UDC v1) to deploy the Garaga verifier
- We passed the verifier class hash as the first argument and set the rest to zeros (no constructor parameters)

### Verify the proof on Ztarknet

Serialize the Noir proof as contract calldata:

```bash
garaga calldata --system ultra_starknet_zk_honk --proof circuit/target/proof --vk circuit/target/vk --public-inputs circuit/target/public_inputs > calldata.txt
```

First, call the verifier contract (without creating a transaction):

```bash
sncast call \
    --contract-address 0x02048def58e122c910f80619ebab076b0ef5513550d38afdfdf2d8a1710fa7c6 \
    --function "verify_ultra_starknet_zk_honk_proof" \
    --calldata $(cat calldata.txt)
```

Now invoke the verifier contract:

```bash
sncast invoke \
  --contract-address 0x02048def58e122c910f80619ebab076b0ef5513550d38afdfdf2d8a1710fa7c6 \
  --function "verify_ultra_starknet_zk_honk_proof" \
  --calldata $(cat calldata.txt)
```

Check the transaction in the [explorer](https://explorer-zstarknet.d.karnot.xyz/).

## Add a simple frontend

A single page app that generates a proof and calls a previously deployed contract.

```bash
make artifacts
```

Install bun, JS dependencies, and run the app:

```bash
cd app
curl -fsSL https://bun.sh/install | bash
bun install
bun run serve
```

## Get help

Something went wrong?

Ask us in the [Zypherpunk hackathon chat](https://t.me/+euCua6eocTc1NmM1).
### Create and deploy your account

```
make account-create
```

Go to the [faucet](https://faucet.ztarknet.cash/) and top up your account address.

```
make account-deploy
```

Make sure you received the funds:

```
make account-balance
```

## Deploy application

### Installation

Install Noir development toolchain:

```
make install-noir
make install-barretenberg
```

Install Garaga SDK & CLI:

```
pip install garaga==0.18.1
```

> [!NOTE]
> Python 3.10 is required to install Garaga.
> Use `pyenv` to manage your Python versions.

### Create and prove a circuit

Start with creating a new Noir project:

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

Prove the circuit:

```bash
bb prove --scheme ultra_honk --zk --oracle_hash starknet -b ./target/circuit.json -w ./target/witness.gz -o ./target
```

Generate a verifying key:

```bash
bb write_vk --scheme ultra_honk --oracle_hash starknet -b ./target/circuit.json -o ./target
```

### Generate and verifier contract

Let Garaga automatically generate a Scarb project for you:

```bash
garaga gen --system ultra_starknet_zk_honk --vk ./circuit/target/vk --project-name verifier
```

Now we can build the contract:

```bash
scarb build
```

### Deploy verifier contract

First we need to declare the contract ("upload it's code hash to the network"):

```bash
# In the root dir
cd verifier && sncast declare --contract-name UltraStarknetZKHonkVerifier
```

Then we can instantiate it (change class-hash according to the output on the previous step):

```bash
# In the root dir
sncast invoke \
  --contract-address 0x041a78e741e5af2fec34b695679bc6891742439f7afb8484ecd7766661ad02bf \
  --function "deployContract" \
  --calldata 0x3575239fa10a4e2bacbf0e2105f8d86473aa19d21441b39675be7fbb5924adf 0x0 0x0 0x0
```

Check the transaction in the [explorer](https://explorer-zstarknet.d.karnot.xyz/) to see the deployed contract address (see events).

What just happened:
- We asked universal deployer contract (UDC v1) to deploy Garaga verifier
- We passed verifier class hash as a first argument and set the rest to zeros (no constructor parameters)

### Verify the proof on Ztarknet

Serialize Noir proof as contract calldata:

```bash
garaga calldata --system ultra_starknet_zk_honk --proof circuit/target/proof --vk circuit/target/vk --public-inputs circuit/target/public_inputs > calldata.txt
```

Let's first call the verifier contract (without creating a transaction):

```bash
sncast call \
    --contract-address 0x02048def58e122c910f80619ebab076b0ef5513550d38afdfdf2d8a1710fa7c6 \
    --function "verify_ultra_starknet_zk_honk_proof" \
    --calldata $(cat calldata.txt)
```

Now let's invoke the verifier contract:

```bash
sncast invoke \
  --contract-address 0x02048def58e122c910f80619ebab076b0ef5513550d38afdfdf2d8a1710fa7c6 \
  --function "verify_ultra_starknet_zk_honk_proof" \
  --calldata $(cat calldata.txt)
```

Check the transaction in the [explorer](https://explorer-zstarknet.d.karnot.xyz/).

## Add a simple frontend

A single page app that generates a proof and calls a previously deployed contract.

First, copy all the necessary artifacts to the app folder:

```bash
make artifacts
```

Install bun, js dependencies, and run the app:

```bash
cd app
curl -fsSL https://bun.sh/install | bash
bun install
bun run serve
```

## Get help

Something got wrong?

Ask us in the [Zypherpunk hackathon chat](https://t.me/+euCua6eocTc1NmM1).

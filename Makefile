URL=https://ztarknet-madara.d.karnot.xyz
ACCOUNT_NAME=ztarknet
ACCOUNT_CLASS_HASH=0x01484c93b9d6cf61614d698ed069b3c6992c32549194fc3465258c2194734189
FEE_TOKEN_ADDRESS=0x1ad102b4c4b3e40a51b6fb8a446275d600555bd63a95cdceed3e5cef8a6bc1d

account-create:
	sncast account create \
		--class-hash $(ACCOUNT_CLASS_HASH) \
		--type oz \
		--url $(URL) \
		--name $(ACCOUNT_NAME)

account-topup:
	@echo "Getting account address..."
	@ADDR=$$(sncast account list 2>/dev/null | grep -A 10 "$(ACCOUNT_NAME)" | grep "address:" | awk '{print $$2}'); \
	if [ -z "$$ADDR" ]; then \
		echo "Error: Account '$(ACCOUNT_NAME)' not found."; \
		echo "Run 'make account-create' first to create the account."; \
		exit 1; \
	fi; \
	echo "Account address: $$ADDR"; \
	cd admin && TOPUP_ADDRESS=$$ADDR npm run topup

account-deploy:
	sncast account deploy \
		--url $(URL) \
		--name $(ACCOUNT_NAME)

account-balance:
	sncast balance \
		--token-address $(FEE_TOKEN_ADDRESS) \
		--url $(URL)

## Install dependencies (Automated)

install-sncast:
	-./scripts/install-sncast.sh

install-noir:
	-./scripts/install-noir.sh

install-scarb:
	-./scripts/install-scarb.sh

install-barretenberg:
	-./scripts/install-barretenberg.sh

install-all: install-sncast install-noir install-scarb install-barretenberg
	@echo ""
	@echo "================================"
	@echo "Installation Summary"
	@echo "================================"
	@echo ""
	@command -v sncast >/dev/null 2>&1 && echo "✓ sncast: $$(sncast --version 2>&1 | head -1)" || echo "✗ sncast: Not installed (manual setup required)"
	@command -v nargo >/dev/null 2>&1 && echo "✓ nargo: $$(nargo --version 2>&1 | head -1)" || echo "✗ nargo: Not installed"
	@command -v scarb >/dev/null 2>&1 && echo "✓ scarb: $$(scarb --version 2>&1 | head -1)" || echo "✗ scarb: Not installed"
	@command -v bb >/dev/null 2>&1 && echo "✓ bb: $$(bb --version 2>&1)" || echo "✗ bb: Not installed"
	@command -v npm >/dev/null 2>&1 && echo "✓ npm: $$(npm --version)" || echo "✗ npm: Not installed"
	@echo ""
	@echo "Next steps:"
	@echo "  1. make install-sncast    # If sncast is not installed"
	@echo "  2. make account-create    # Create a new account"
	@echo "  3. make account-deploy    # Deploy the account"
	@echo ""

setup:
	./scripts/setup.sh

## Copy artifacts to app folder

artifacts:
	cp ./circuit/target/circuit.json ./app/src/assets/circuit.json
	cp ./circuit/target/vk ./app/src/assets/vk.bin
	@if [ -f ./verifier/target/release/verifier_UltraStarknetZKHonkVerifier.contract_class.json ]; then \
	  cp ./verifier/target/release/verifier_UltraStarknetZKHonkVerifier.contract_class.json ./app/src/assets/verifier.json; \
	  echo "Copied verifier.json"; \
	else \
	  echo "Skipping verifier.json (build optional and not found)"; \
	fi

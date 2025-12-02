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
	cd admin && TOPUP_ADDRESS=$$(sncast account list | grep -A 10 "$(ACCOUNT_NAME)" | grep "address:" | awk '{print $$2}') npm run topup

account-deploy:
	sncast account deploy \
		--url $(URL) \
		--name $(ACCOUNT_NAME)

account-balance:
	sncast balance \
		--token-address $(FEE_TOKEN_ADDRESS) \
		--url $(URL)

## Install dependencies


# Instala Noir CLI 1.0.0-beta.1
install-noir:
	cargo install --locked --version 1.0.0-beta.1 noir



# Instala Barretenberg (bb) 0.67.0
install-barretenberg:
	curl -L -o bb.tar.gz "<url_release_bb>"
	tar -xzf bb.tar.gz
	sudo mv bb /usr/local/bin/
	rm -f bb.tar.gz

# Instala Scarb 2.9.2
install-scarb:
	cargo install --locked --version 2.9.2 scarb

## Copy artifacts to app folder

artifacts:
	cp ./circuit/target/circuit.json ./app/src/assets/circuit.json
	cp ./circuit/target/vk ./app/src/assets/vk.bin
	cp ./verifier/target/release/verifier_UltraStarknetZKHonkVerifier.contract_class.json ./app/src/assets/verifier.json
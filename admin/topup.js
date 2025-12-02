require('dotenv').config();
const starknet = require('starknet');
const ERC20 = require('./ERC20.json');

const recipient = process.env.TOPUP_ADDRESS;
const fee_token_address = '0x1ad102b4c4b3e40a51b6fb8a446275d600555bd63a95cdceed3e5cef8a6bc1d';

// Validate required environment variables
if (!recipient) {
    console.error('Error: TOPUP_ADDRESS is not set.');
    console.error('This script requires TOPUP_ADDRESS environment variable.');
    console.error('');
    console.error('Make sure you created an account first:');
    console.error('  make account-create');
    process.exit(1);
}

if (!process.env.ADMIN_ADDRESS || !process.env.ADMIN_KEY) {
    console.error('========================================');
    console.error('Admin Configuration Missing');
    console.error('========================================');
    console.error('');
    console.error('This automated topup script requires an admin account with STRK tokens.');
    console.error('');
    console.error('RECOMMENDED: Use the manual faucet instead:');
    console.error('  1. Visit: https://faucet.ztarknet.cash/');
    console.error('  2. Paste your account address from "make account-create"');
    console.error('  3. Request tokens');
    console.error('');
    console.error('ALTERNATIVE: Configure automated topup:');
    console.error('  1. Copy admin/.env.example to admin/.env');
    console.error('  2. Add your admin account address and private key');
    console.error('  3. Run "make account-topup" again');
    console.error('');
    process.exit(1);
}

const provider = new starknet.RpcProvider({
    nodeUrl: 'https://ztarknet-madara.d.karnot.xyz',
});
const account = new starknet.Account({
    provider,
    address: process.env.ADMIN_ADDRESS,
    signer: process.env.ADMIN_KEY,
    cairoVersion: '1',
    transactionVersion: '0x3',
    defaultTipType: 'recommendedTip',
});

async function transfer() {
    const contract = new starknet.Contract({
        abi: ERC20.abi,
        address: fee_token_address,
        providerOrAccount: provider,
    });
    const nonce = await provider.getNonceForAddress(
        account.address,
        'pre_confirmed'
    );
    let result = contract.populate('transfer', {
        recipient,
        amount: {
            low: 0,
            high: 1,
        },
    });

    let tx_result = await account.execute(result, {
        blockIdentifier: 'pre_confirmed',
        tip: 1000n,
        nonce,
    });
    const receipt = await provider.waitForTransaction(
        tx_result.transaction_hash,
        {
            retryInterval: 100,
        }
    );
    console.log('receipt - ', receipt);
}

transfer();
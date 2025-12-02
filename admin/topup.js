require('dotenv').config();
const starknet = require('starknet');
const ERC20 = require('./ERC20.json');

const recipient = process.env.TOPUP_ADDRESS;
const fee_token_address = '0x1ad102b4c4b3e40a51b6fb8a446275d600555bd63a95cdceed3e5cef8a6bc1d';

// Validate required environment variables
if (!recipient) {
    console.error('Error: TOPUP_ADDRESS is not set.');
    console.error('Please run: make account-create');
    console.error('Or set TOPUP_ADDRESS environment variable manually.');
    process.exit(1);
}

if (!process.env.ADMIN_ADDRESS) {
    console.error('Error: ADMIN_ADDRESS is not set in .env file.');
    console.error('Please configure admin/.env with ADMIN_ADDRESS and ADMIN_KEY.');
    process.exit(1);
}

if (!process.env.ADMIN_KEY) {
    console.error('Error: ADMIN_KEY is not set in .env file.');
    console.error('Please configure admin/.env with ADMIN_ADDRESS and ADMIN_KEY.');
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
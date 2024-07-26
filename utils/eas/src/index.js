import { SchemaRegistry } from '@ethereum-attestation-service/eas-sdk';
import * as dotenv from 'dotenv';
import { JsonRpcProvider } from 'ethers';
import { Wallet } from 'ethers';
import minimist from 'minimist';
import { getSchemaRegistry } from './helper.js';

dotenv.config();
const ENV = process.env.NODE_ENV;
const JSON_RPC_PROVIDER =
  ENV === 'development'
    ? process.env.JSON_RPC_PROVIDER_TESTNET
    : process.env.JSON_RPC_PROVIDER;
const ATTESTATOR_SIGNER_PRIVATE_KEY = process.env.ATTESTATOR_SIGNER_PRIVATE_KEY;

async function registerSchema(resolverAddress) {
  const schemaString = '(uint256 badgeId, uint256 level)[] badges';
  const provider = new JsonRpcProvider(JSON_RPC_PROVIDER);
  const wallet = new Wallet(ATTESTATOR_SIGNER_PRIVATE_KEY, provider);

  const schemaRegistryContractAddress = getSchemaRegistry(ENV);
  const schemaRegistry = new SchemaRegistry(schemaRegistryContractAddress);
  schemaRegistry.connect(wallet);

  const transaction = await schemaRegistry.register({
    schema: schemaString,
    resolverAddress,
    revocable: false,
  });
  const receipt = await transaction.wait();
  return receipt;
}

const args = minimist(process.argv.slice(2), {
  string: ['resolver'],
});
const resolverAddress = args.resolver;
if (!resolverAddress) {
  console.error(
    'Please provide a resolver address using --resolver <resolverAddress>.'
  );
  process.exit(1);
}

registerSchema(resolverAddress)
  .then((receipt) => {
    console.log('Transaction receipt:', receipt);
  })
  .catch((error) => {
    console.error('Error registering schema:', error);
  });

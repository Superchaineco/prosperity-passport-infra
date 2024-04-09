import { EAS__factory } from '@ethereum-attestation-service/eas-contracts/dist/typechain-types/factories/contracts/EAS__factory';
import { SchemaEncoder } from '@ethereum-attestation-service/eas-sdk';
import { ethers } from 'ethers';

const easContractAddress = process.env.EAS_CONTRACT_ADDRESS!;
const schemaString = 'uint256 DPGPoints';
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL!);
const wallet = new ethers.Wallet(
  process.env.ATTESTATOR_SIGNER_PRIVATE_KEY!,
  provider
);
const eas = EAS__factory.connect(easContractAddress, wallet);
const schemaEncoder = new SchemaEncoder(schemaString);

export async function attest(
  superChainSmartAccount: string,
  totalPoints: number
) {
  const schemaUID = process.env.SCHEMA_UID!;
  const encodedData = schemaEncoder.encodeData([
    { name: 'DPGPoints', value: totalPoints, type: 'uint256' },
  ]);

  try {
    const tx = await eas.attest({
      schema: schemaUID,
      data: {
        recipient: superChainSmartAccount,
        expirationTime: BigInt(0),
        refUID: ethers.ZeroHash,
        revocable: false,
        data: encodedData,
        value: BigInt(0),
      },
    });

    const receipt = await tx.wait();
    console.log(`Attestation successful. Transaction hash: ${receipt?.hash}`);
    return receipt;
  } catch (error: any) {
    console.error('Error attesting', error);
    throw new Error(error);
  }
}

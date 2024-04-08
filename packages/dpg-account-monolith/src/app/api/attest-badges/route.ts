import { badgesService } from '@/services/BadgesService';
import { NextRequest, NextResponse } from 'next/server';
import { EAS__factory } from '@ethereum-attestation-service/eas-contracts/dist/typechain-types/factories/contracts/EAS__factory';

import {
  EAS,
  Offchain,
  SchemaEncoder,
  SchemaRegistry,
} from '@ethereum-attestation-service/eas-sdk';
import { ethers } from 'ethers';

const easContractAddress = process.env.EAS_CONTRACT_ADDRESS!;
const schemaString = 'uint256 DPGPoints';
const provider = new ethers.JsonRpcProvider(process.env.JSON_RPC!);
const wallet = new ethers.Wallet(
  process.env.ATTESTATOR_SIGNER_PRIVATE_KEY!,
  provider
);
const eas = EAS__factory.connect(easContractAddress, wallet);
const schemaEncoder = new SchemaEncoder(schemaString);

export async function POST(req: NextRequest) {
  const data = await req.json();
  const schemaUID = process.env.SCHEMA_UID!;
  if (!data.eoas) {
    return NextResponse.error();
  }
  const badges = await badgesService.getBadges(data.eoas?.split(','));
  const totalPoints = badges.reduce((acc, badge) => {
    return acc + badge.points;
  }, 0);
  const encodedData = schemaEncoder.encodeData([
    { name: 'DPGPoints', value: totalPoints, type: 'uint256' },
  ]);

  try {
    const tx = await eas.attest({
      schema: schemaUID,
      data: {
        recipient: data.superChainSmartAccount,
        expirationTime: BigInt(0),
        refUID: ethers.ZeroHash,
        revocable: false,
        data: encodedData,
        value: BigInt(0),
      },
    });

    const receipt = await tx.wait();
    console.log(`Attestation successful. Transaction hash: ${receipt?.hash}`);

    return NextResponse.json({ hash: receipt?.hash }, { status: 201 });
  } catch (error) {
    console.error('Error attesting', error);
    return NextResponse.json({ error }, { status: 500 });
  }
}

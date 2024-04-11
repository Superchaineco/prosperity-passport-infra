import { NextRequest, NextResponse } from 'next/server';
import { type IVerifyResponse, verifyCloudProof } from '@worldcoin/idkit';

export async function POST(req: NextRequest) {
  const { proof, signal } = await req.json();
  const app_id = process.env.APP_ID as `app_${string}`;
  const action = process.env.ACTION_ID!;
  const verifyRes = (await verifyCloudProof(
    proof,
    app_id,
    action,
    signal
  )) as IVerifyResponse;

  if (verifyRes.success) {
    return NextResponse.json(verifyRes, { status: 200 });
  } else {
    return NextResponse.error();
  }
}

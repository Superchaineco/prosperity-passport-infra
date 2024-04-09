import { attestationsService } from '@/services/Attestations.service';
import { badgesService } from '@/services/Badges.service';
import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  const data = await req.json();
  if (!data.eoas) {
    return NextResponse.error();
  }
  const badges = await badgesService.getBadges(data.eoas, data.account);
  const totalPoints = badges.reduce((acc, badge) => {
    return acc + badge.points;
  }, 0);

  try {
    const receipt = await attestationsService.attest(
      data.superChainSmartAccount,
      totalPoints,
      badges
    );

    return NextResponse.json({ hash: receipt?.hash }, { status: 201 });
  } catch (error) {
    console.error('Error attesting', error);
    return NextResponse.json({ error }, { status: 500 });
  }
}

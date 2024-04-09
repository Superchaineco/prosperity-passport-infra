import { badgesService } from '@/services/Badges.service';
import { NextRequest, NextResponse } from 'next/server';

export async function GET(req: NextRequest) {
  const eoas = new Headers().get('address');
  if (!eoas) {
    return NextResponse.error();
  }
  const badges = await badgesService.getBadges(eoas?.split(','));
  const totalPoints = badges.reduce((acc, badge) => {
    return acc + badge.points;
  }, 0);
  return NextResponse.json({
    totalPoints,
    badges,
  });
}

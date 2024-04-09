import { badgesService } from '@/services/Badges.service';
import { createClient } from '@/services/Supabase.service';
import { NextRequest, NextResponse } from 'next/server';

export async function GET(req: NextRequest) {
  const eoas = new Headers().get('address')?.split(',');
  const account = new Headers().get('account');

  if (!eoas || !account) {
    return NextResponse.error();
  }

  const currentBadges = await badgesService.getBadges(eoas, account);
  const totalPoints = currentBadges.reduce((acc, badge) => {
    return acc + badge.points;
  }, 0);
  return NextResponse.json({
    totalPoints,
    currentBadges,
  });
}

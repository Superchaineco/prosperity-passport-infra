import { badgesService } from '@/services/Badges.service';
import { createClient } from '@/services/Supabase.service';
import { NextRequest, NextResponse } from 'next/server';

const supabase = createClient();

export async function GET(req: NextRequest) {
  const eoas = new Headers().get('address')?.split(',');
  if (!eoas) {
    return NextResponse.error();
  }
  await Promise.all(
    eoas.map(async (address) => {
      let { data: account, error: accountError } = await supabase
        .from('Account')
        .select('*')
        .eq('address', address)
        .single();

      if (!account && !accountError) {
        await supabase.from('Account').insert([{ address }]);
      }
    })
  );

  const currentBadges = await badgesService.getBadges(eoas);
  const totalPoints = currentBadges.reduce((acc, badge) => {
    return acc + badge.points;
  }, 0);
  return NextResponse.json({
    totalPoints,
    currentBadges,
  });
}

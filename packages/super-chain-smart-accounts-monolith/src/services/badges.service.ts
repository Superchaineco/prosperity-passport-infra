import { createClient } from './supabase.service';
import { BadgesHelper, IBadgesHelper } from './badges.helper';

export type Badge = {
  points: number;
  name: string;
  id: string;
};

class BadgesServices {
  private supabase = createClient();
  private badges: Badge[] = [];
  private helper: IBadgesHelper;

  constructor() {
    this.helper = new BadgesHelper(this.supabase);
  }

  public async getBadges(eoas: string[], account: string): Promise<Badge[]> {
    const { data: _account, error: accountError } = await this.supabase
      .from('Account')
      .select('*')
      .eq('address', account)
      .single();

    if (!account && !accountError) {
      await this.supabase.from('Account').insert([{ account }]);
    }
    const activeBadges = await this.getActiveBadges();

    for (const badge of activeBadges) {
      const { data: accountBadge, error } = await this.supabase
        .from('AccountBadges')
        .select('*')
        .eq('badgeId', badge.id)
        .eq('account', account)
        .eq('isDeleted', false)
        .single();

      if (error) {
        console.error(`Error fetching badge for account ${account}:`, error);
        continue;
      }

      let params = {};
      if (accountBadge) {
        params =
          badge.dataOrigin === 'onChain'
            ? { blockNumber: accountBadge.lastClaimBlock }
            : { timestamp: accountBadge.lastClaim };
      }

      await this.updateBadgeDataForAccount(account, eoas, badge, params);
    }

    return this.badges;
  }

  private async updateBadgeDataForAccount(
    account: string,
    eoas: string[],
    badge: Badge,
    params: any
  ) {
    console.log(
      `Actualizando datos para la badge ${badge.name} del usuario ${account} con parámetros:`,
      params
    );
    switch (badge.name) {
      case 'Optimism Transactions':
        const newPoints = await this.helper.getOptimisimTransactions(
          eoas,
          params.blockNumber
        );
        this.badges.push({ name: badge.name, points: newPoints, id: badge.id });
        break;
      case 'Base Transactions':
        const newBasePoints = await this.helper.getBaseTransactions(
          eoas,
          params.blockNumber
        );
        this.badges.push({
          name: badge.name,
          points: newBasePoints,
          id: badge.id,
        });
        break;

      case 'Citizen':
        const isCitizen = await this.helper.isCitizen(eoas);
        this.badges.push({
          name: badge.name,
          points: isCitizen ? 100 : 0,
          id: badge.id,
        });
        break;

      case 'Nouns':
        const countNouns = await this.helper.hasNouns(eoas);
        this.badges.push({
          name: badge.name,
          points: countNouns,
          id: badge.id,
        });
        break;
    }
  }

  private async getActiveBadges() {
    const { data: badges, error } = await this.supabase
      .from('Badges')
      .select('*')
      .eq('isActive', true);

    if (error) {
      console.error('Error fetching active badges:', error);
      return [];
    }

    return badges;
  }
}

export const badgesService = new BadgesServices();

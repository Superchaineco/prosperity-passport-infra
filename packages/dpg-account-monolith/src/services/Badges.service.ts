import { Alchemy, AssetTransfersCategory, Network } from 'alchemy-sdk';
import { createClient } from './Supabase.service';

type Badge = {
  points: number;
  name: string;
};

class BadgesServices {
  private supabase = createClient();
  private badges: Badge[] = [];

  private async getOptimisimTransactions(
    eoas: string[],
    block: string
  ): Promise<number> {
    const settings = {
      apiKey: process.env.ALCHEMY_PRIVATE_KEY!,
      network: Network.OPT_MAINNET,
    };

    const alchemy = new Alchemy(settings);
    const transactions = await eoas.reduce(async (accPromise, eoa) => {
      const acc = await accPromise;
      const res = await alchemy.core.getAssetTransfers({
        fromBlock: block,
        toBlock: 'latest',
        toAddress: eoa,
        excludeZeroValue: true,
        category: [
          AssetTransfersCategory.ERC20,
          AssetTransfersCategory.ERC1155,
          AssetTransfersCategory.EXTERNAL,
          AssetTransfersCategory.INTERNAL,
          AssetTransfersCategory.ERC721,
        ],
      });

      return acc + res.transfers.length;
    }, Promise.resolve(0));

    return transactions;
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

    const optimismTransactionsPoints = await this.getOptimisimTransactions(
      eoas,
      '10'
    );
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

    if (badge.name === 'Optimism Transactions') {
      const newPoints = await this.getOptimisimTransactions(
        eoas,
        params.blockNumber
      );
      this.badges.push({ name: badge.name, points: newPoints });
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

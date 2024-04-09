import { Alchemy, AssetTransfersCategory, Network } from 'alchemy-sdk';

type Badge = {
  points: number;
  name: string;
};

class BadgesServices {
  private async getOptimisimTransactions(eoas: string[]): Promise<number> {
    const settings = {
      apiKey: process.env.ALCHEMY_PRIVATE_KEY!,
      network: Network.OPT_MAINNET,
    };

    const alchemy = new Alchemy(settings);
    const transactions = await eoas.reduce(async (accPromise, eoa) => {
      const acc = await accPromise;
      const res = await alchemy.core.getAssetTransfers({
        fromBlock: '0x0',
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

  public async getBadges(eoas: string[]): Promise<Badge[]> {
    const optimismTransactionsPoints = await this.getOptimisimTransactions(
      eoas
    );
    return [
      {
        points: optimismTransactionsPoints,
        name: 'Optimism Transactions',
      },
    ];
  }
}

export const badgesService = new BadgesServices();

import { useWeb3ReadOnly } from '@/hooks/wallets/web3';
import { useWallet } from '../useWallet';
import useAsync, { AsyncResult } from '../useAsync';

const useWalletBalance = (): AsyncResult<bigint | undefined> => {
  const web3ReadOnly = useWeb3ReadOnly();
  const { wallet } = useWallet();

  return useAsync<bigint | undefined>(async () => {
    if (!wallet || !web3ReadOnly) {
      return undefined;
    }

    const balance = await web3ReadOnly.getBalance(wallet.address, 'latest');
    return balance;
  }, [wallet, web3ReadOnly]);
};

export default useWalletBalance;

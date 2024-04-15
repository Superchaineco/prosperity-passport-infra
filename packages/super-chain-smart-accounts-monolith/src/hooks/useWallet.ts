import { EIP1193Provider, useWallets } from '@privy-io/react-auth';
import { useEffect, useState } from 'react';

export type ConnectedWallet = {
  label: string;
  chainId: string;
  address: string;
  ens?: string;
  provider: EIP1193Provider;
  icon?: string;
  balance?: string;
};
function useWallet() {
  const [wallet, setWallet] = useState<ConnectedWallet | null>(null);
  const [isReady, setIsReady] = useState(false);
  const { wallets } = useWallets();
  const currentWallet = wallets[0];
  useEffect(() => {
    (async () => {
      setWallet({
        label: 'Privy',
        chainId: currentWallet.chainId,
        address: currentWallet.address,
        provider: await currentWallet.getEthereumProvider(),
        icon: currentWallet.meta.icon,
        balance: '0',
      });
      setIsReady(true);
    })();
  }, [currentWallet]);

  return { wallet, isReady };
}

export { useWallet };

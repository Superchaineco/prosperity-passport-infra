import type { ReactElement } from 'react';
import AccountCenter from '@/components/common/ConnectWallet/AccountCenter';
import { usePrivy, useWallets } from '@privy-io/react-auth';
import { ConnectionCenter } from './ConnectionCenter';
import { useWallet } from '@/hooks/useWallet';

const ConnectWallet = (): ReactElement => {
  const { authenticated } = usePrivy();
  const { wallet, isReady } = useWallet();

  return authenticated && isReady ? (
    <AccountCenter wallet={wallet!} />
  ) : (
    <ConnectionCenter />
  );
};

export default ConnectWallet;

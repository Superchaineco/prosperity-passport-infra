import type { ReactElement } from 'react';
import { useCallback } from 'react';
import { Box, Button } from '@mui/material';
import css from './styles.module.css';
import { useWallet } from '@/hooks/useWallet';
import { usePrivy, useWallets } from '@privy-io/react-auth';

const ChainSwitcher = ({
  fullWidth,
}: {
  fullWidth?: boolean;
}): ReactElement | null => {
  const { wallet } = useWallet();
  const {} = usePrivy();
  const { wallets } = useWallets();

  const handleChainSwitch = useCallback(async () => {
    wallets[0].switchChain(10);
  }, [wallets]);

  console.debug('wallet', wallet);
  if (!wallet || wallet?.chainId == 'eip155:10') return null;

  return (
    <Button
      onClick={handleChainSwitch}
      variant='outlined'
      size='small'
      fullWidth={fullWidth}
      color='primary'
    >
      Switch to&nbsp;
      <Box className={css.circle} bgcolor={'#FF0420'} />
      &nbsp;Optimism
    </Button>
  );
};

export default ChainSwitcher;

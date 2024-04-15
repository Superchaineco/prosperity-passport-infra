import WalletBalance from '@/components/common/WalletBalance';
import { WalletIdenticon } from '@/components/common/WalletOverview';
import { Box, Button, Typography } from '@mui/material';
import css from './styles.module.css';
import EthHashInfo from '@/components/common/EthHashInfo';
import ChainSwitcher from '@/components/common/ChainSwitcher';
import PowerSettingsNewIcon from '@mui/icons-material/PowerSettingsNew';
import { ConnectedWallet } from '@/hooks/useWallet';
import { usePrivy } from '@privy-io/react-auth';

type WalletInfoProps = {
  wallet: ConnectedWallet;
  balance?: string | bigint;
  currentChainId: string;
  handleClose: () => void;
};

export const WalletInfo = ({
  wallet,
  balance,
  currentChainId,
  handleClose,
}: WalletInfoProps) => {
  const { logout } = usePrivy();

  const handleDisconnect = () => {
    logout();

    handleClose();
  };

  return (
    <>
      <Box display='flex' gap='12px'>
        <WalletIdenticon wallet={wallet} size={36} />
        <Typography variant='body2' className={css.address} component='div'>
          <EthHashInfo
            address={wallet.address}
            name={wallet.ens || wallet.label}
            showAvatar={false}
            showPrefix={false}
            hasExplorer
            showCopyButton
            prefix={''}
          />
        </Typography>
      </Box>

      <Box className={css.rowContainer}>
        <Box className={css.row}>
          <Typography variant='body2' color='primary.light'>
            Wallet
          </Typography>
          <Typography variant='body2'>{wallet.label}</Typography>
        </Box>

        <Box className={css.row}>
          <Typography variant='body2' color='primary.light'>
            Balance
          </Typography>
          <Typography variant='body2' textAlign='right'>
            <WalletBalance balance={balance} />

            {currentChainId !== '10' && (
              <>
                <Typography variant='body2' color='primary.light'>
                  ({'Optimism'})
                </Typography>
              </>
            )}
          </Typography>
        </Box>
      </Box>

      <Box display='flex' flexDirection='column' gap={2} width={1}>
        <ChainSwitcher fullWidth />

        <Button
          onClick={handleDisconnect}
          variant='danger'
          size='small'
          fullWidth
          disableElevation
          startIcon={<PowerSettingsNewIcon />}
        >
          Disconnect
        </Button>
      </Box>
    </>
  );
};

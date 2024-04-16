import { Alert, AlertTitle, Box } from '@mui/material';
import ChainSwitcher from '@/components/common/ChainSwitcher';
import { useWallet } from '@/hooks/useWallet';

const NetworkWarning = () => {
  const { wallet } = useWallet();

  if (!wallet?.chainId) return null;

  return (
    <Alert severity='warning' sx={{ mt: 3 }}>
      <AlertTitle sx={{ fontWeight: 700 }}>
        Change your wallet network
      </AlertTitle>
      You are trying to create a Superchain Account on OP Mainnet. Make sure
      that your wallet is set to the same network.
      <Box mt={2}>
        <ChainSwitcher />
      </Box>
    </Alert>
  );
};

export default NetworkWarning;

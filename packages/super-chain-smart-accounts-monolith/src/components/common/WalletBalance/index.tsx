import { formatVisualAmount } from '@/utils/formatters';
import { Skeleton } from '@mui/material';

const WalletBalance = ({
  balance,
}: {
  balance: string | bigint | undefined;
}) => {
  if (balance === undefined) {
    return (
      <Skeleton width={30} variant='text' sx={{ display: 'inline-block' }} />
    );
  }

  if (typeof balance === 'string') {
    return <>{balance}</>;
  }

  return (
    <>
      {formatVisualAmount(balance, 18)} {'OETH'}
    </>
  );
};

export default WalletBalance;

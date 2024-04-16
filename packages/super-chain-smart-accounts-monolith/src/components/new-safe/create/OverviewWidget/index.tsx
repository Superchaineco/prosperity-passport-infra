import { Card, Grid, Typography } from '@mui/material';
import type { ReactElement } from 'react';
import SafeLogo from '@/public/images/logo-no-text.svg';

import css from '@/components/new-safe/create/OverviewWidget/styles.module.css';
import { useWallet } from '@/hooks/useWallet';
import WalletOverview from '../../../common/WalletOverview';
import ChainIndicator from '../../../common/ChainIndicator';

const LOGO_DIMENSIONS = '22px';

const OverviewWidget = ({
  safeName,
}: {
  safeName: string;
}): ReactElement | null => {
  const { wallet } = useWallet();
  const rows = [
    ...(wallet
      ? [{ title: 'Wallet', component: <WalletOverview wallet={wallet} /> }]
      : []),
    ...(wallet
      ? [
          {
            title: 'Network',
            component: <ChainIndicator inline />,
          },
        ]
      : []),
    ...(safeName !== ''
      ? [{ title: 'Name', component: <Typography>{safeName}</Typography> }]
      : []),
  ];

  return (
    <Grid item xs={12}>
      <Card className={css.card}>
        <div className={css.header}>
          <Typography variant='h4'>Your Superchain Account preview</Typography>
        </div>
        {wallet ? (
          rows.map((row) => (
            <div key={row.title} className={css.row}>
              <Typography variant='body2'>{row.title}</Typography>
              {row.component}
            </div>
          ))
        ) : (
          <div className={css.row}>
            <Typography
              variant='body2'
              color='border.main'
              textAlign='center'
              width={1}
            >
              Connect your wallet to continue
            </Typography>
          </div>
        )}
      </Card>
    </Grid>
  );
};

export default OverviewWidget;

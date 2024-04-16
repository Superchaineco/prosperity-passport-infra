import { Container, Typography, Grid } from '@mui/material';
import { useRouter } from 'next/navigation';

import type { AlertColor } from '@mui/material';
import { type ReactElement, useMemo, useState } from 'react';
import ExternalLink from '@/components/common/ExternalLink';
import { useWallet } from '@/hooks/useWallet';
import { NamedAddress } from './types';
import { CreateSafeInfoItem } from './CreateSafeInfos';
import { TxStepperProps } from '../CardStepper/useCardStepper';
import { CardStepper } from '../CardStepper';
import SuperChainID from './steps/SuperChainId';
import OverviewWidget from './OverviewWidget';

export type NewSafeFormData = {
  name: string;
  threshold: number;
  saltNonce: number;
  safeAddress?: string;
  willRelay?: boolean;
};

const CreateSafe = () => {
  const router = useRouter();
  const [activeStep, setActiveStep] = useState(0);
  const [walletName, setWalletName] = useState('');
  const [superChainId, setSuperChainId] = useState('')


  const CreateSafeSteps: TxStepperProps<NewSafeFormData>['steps'] = [
    {
      title: 'Select a name and ID for your Superchain Account',
      subtitle: '',
      render: (data, onSubmit, onBack, setStep) => (
        <SuperChainID setSuperChainId={setSuperChainId} setWalletName={setWalletName} />
      ),
    },
    {
      title: 'Signers and confirmations',
      subtitle:
        'Set the signer wallets of your Safe Account and how many need to confirm to execute a valid transaction.',
      render: (data, onSubmit, onBack, setStep) => <h1>Hello</h1>,
    },
    {
      title: 'Review',
      subtitle:
        "You're about to create a new Safe Account and will have to confirm the transaction with your connected wallet.",
      render: (data, onSubmit, onBack, setStep) => <h1>Hello</h1>,
    },
    {
      title: '',
      subtitle: '',
      render: (data, onSubmit, onBack, setStep, setProgressColor) => (
        <h1>Hello</h1>
      ),
    },
  ];

  const initialStep = 0;

  const initialData: NewSafeFormData = {
    name: '',
    threshold: 1,
    saltNonce: Date.now(),
  };

  const onClose = () => {
    router.push('/');
  };

  return (
    <Container>
      <Grid
        container
        columnSpacing={3}
        justifyContent='center'
        mt={[2, null, 7]}
      >
        <Grid item xs={12}>
          <Typography variant='h2' pb={2}>
            Create new Safe Account
          </Typography>
        </Grid>
        <Grid item xs={12} md={8} order={[1, null, 0]}>
          <CardStepper
            initialData={initialData}
            initialStep={initialStep}
            onClose={onClose}
            steps={CreateSafeSteps}
            setWidgetStep={setActiveStep}
          />
        </Grid>

        <Grid item xs={12} md={4} mb={[3, null, 0]} order={[0, null, 1]}>
          <Grid container spacing={3}>
            {activeStep < 2 && <OverviewWidget superChainId={superChainId} walletName={walletName} />}
            {/* {wallet?.address && (
              <CreateSafeInfos
                staticHint={staticHint}
                dynamicHint={dynamicHint}
              />
            )} */}
          </Grid>
        </Grid>
      </Grid>
    </Container>
  );
};

export default CreateSafe;

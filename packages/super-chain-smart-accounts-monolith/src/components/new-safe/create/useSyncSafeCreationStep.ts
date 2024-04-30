import { useEffect, useMemo } from 'react';
import type { StepRenderProps } from '@/components/new-safe/CardStepper/useCardStepper';
import type { NewSafeFormData } from '@/components/new-safe/create/index';
import { useRouter } from 'next/navigation';
import { useWallet } from '@/hooks/useWallet';
import useIsWrongChain from '@/hooks/useIsWrongChain';
import { usePendingSafe } from './steps/StatusStep/usePendingSafe';
import { AppRoutes } from '@/config/routes';

const useSyncSafeCreationStep = (
  setStep: StepRenderProps<NewSafeFormData>['setStep']
) => {
  const [pendingSafe] = usePendingSafe();
  const { wallet, isReady } = useWallet();
  const isWrongChain = useIsWrongChain();
  const router = useRouter();

  useEffect(() => {
    // Jump to the status screen if there is already a tx submitted
    if (pendingSafe) {
      setStep(3);
      return;
    }

    // Jump to the welcome page if there is no wallet
    if (!wallet && isReady) {
      router.push(AppRoutes.welcome.index);
    }

    if (isWrongChain && isReady) {
      setStep(0);
      return;
    }
  }, [wallet, setStep, isWrongChain, router, isReady]);
};

export default useSyncSafeCreationStep;

import { useEffect, useMemo } from 'react';
import type { StepRenderProps } from '@/components/new-safe/CardStepper/useCardStepper';
import type { NewSafeFormData } from '@/components/new-safe/create/index';
import { useRouter } from 'next/navigation';
import { useWallet } from '@/hooks/useWallet';

const useSyncSafeCreationStep = (
  setStep: StepRenderProps<NewSafeFormData>['setStep']
) => {
  const { wallet } = useWallet();
  const isWrongChain = useMemo(() => {
    return wallet?.chainId !== 'eip155:10';
  }, [wallet]);
  const router = useRouter();

  useEffect(() => {
    // Jump to the status screen if there is already a tx submitted
    if (false) {
      // setStep(3);
      return;
    }

    // Jump to the welcome page if there is no wallet

    // Jump to choose name and network step if the wallet is connected to the wrong chain and there is no pending Safe
    if (isWrongChain) {
      // setStep(0);
      return;
    }
  }, [wallet, setStep, isWrongChain, router]);
};

export default useSyncSafeCreationStep;

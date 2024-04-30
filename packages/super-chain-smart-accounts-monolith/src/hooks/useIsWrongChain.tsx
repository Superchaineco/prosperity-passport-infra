import React, { useMemo } from 'react';
import { useWallet } from './useWallet';
import useChainId from './useChainId';

function useIsWrongChain() {
  const chainId = useChainId();
  console.debug(chainId);
  const isWrongChain = useMemo(() => {
    return chainId !== '10';
  }, [chainId]);
  return isWrongChain;
}

export default useIsWrongChain;

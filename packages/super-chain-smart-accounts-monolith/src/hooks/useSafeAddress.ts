import { useMemo } from 'react';
import { parsePrefixedAddress } from '@/utils/addresses';
import { useSearchParams } from 'next/navigation';

const useSafeAddress = (): string => {
  const searchParams = useSearchParams();
  const safe = searchParams.get('safe');
  const fullAddress = safe || '';

  const checksummedAddress = useMemo(() => {
    if (!fullAddress) return '';
    const { address } = parsePrefixedAddress(fullAddress);
    return address;
  }, [fullAddress]);

  return checksummedAddress;
};

export default useSafeAddress;

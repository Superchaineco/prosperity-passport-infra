import type { ReactElement } from 'react';
import { useMemo } from 'react';
import classnames from 'classnames';
import css from './styles.module.css';
import { Skeleton } from '@mui/material';
import isEmpty from 'lodash/isEmpty';

type ChainIndicatorProps = {
  chainId?: string;
  inline?: boolean;
  className?: string;
  showUnknown?: boolean;
  showLogo?: boolean;
  responsive?: boolean;
};

const chainConfig = {
  chainName: 'Optimisim',
  chainId: '10',
  theme: {
    backgroundColor: '#FF0420',
    textColor: '#000',
  },
  chainLogoUri:
    'https://safe-transaction-assets.safe.global/chains/10/chain_logo.png',
};

const ChainIndicator = ({
  chainId,
  className,
  inline = false,
  showUnknown = true,
  showLogo = true,
  responsive = false,
}: ChainIndicatorProps): ReactElement | null => {
  const style = useMemo(() => {
    if (!chainConfig) return;
    const { theme } = chainConfig;

    return {
      backgroundColor: theme.backgroundColor,
      color: theme.textColor,
    };
  }, [chainConfig]);

  return (
    <span
      data-testid='chain-logo'
      style={showLogo ? undefined : style}
      className={classnames(className || '', {
        [css.inlineIndicator]: inline,
        [css.indicator]: !inline,
        [css.withLogo]: showLogo,
        [css.responsive]: responsive,
      })}
    >
      {showLogo && (
        <img
          src={chainConfig.chainLogoUri ?? undefined}
          alt={`${chainConfig.chainName} Logo`}
          width={24}
          height={24}
          loading='lazy'
        />
      )}

      <span className={css.name}>{chainConfig.chainName}</span>
    </span>
  );
};

export default ChainIndicator;

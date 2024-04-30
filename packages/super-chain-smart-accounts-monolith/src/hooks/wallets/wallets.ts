import {
  CYPRESS_MNEMONIC,
  TREZOR_APP_URL,
  TREZOR_EMAIL,
  WC_PROJECT_ID,
} from '@/config/constants';
import type { ChainInfo } from '@safe-global/safe-gateway-typescript-sdk';
import type { InitOptions } from '@web3-onboard/core';
import injectedWalletModule from '@web3-onboard/injected-wallets';

import { CGW_NAMES, WALLET_KEYS } from './consts';
const prefersDarkMode = (): boolean => {
  return window?.matchMedia('(prefers-color-scheme: dark)')?.matches;
};

type WalletInits = InitOptions['wallets'];
type WalletInit = WalletInits extends Array<infer U> ? U : never;

const WALLET_MODULES: {
  [key in WALLET_KEYS]: (chain: ChainInfo) => WalletInit;
} = {
  [WALLET_KEYS.INJECTED]: () => injectedWalletModule() as WalletInit,
  [WALLET_KEYS.WALLETCONNECT_V2]: function (chain: ChainInfo): WalletInit {
    throw new Error('Function not implemented.');
  },
  [WALLET_KEYS.SOCIAL]: function (chain: ChainInfo): WalletInit {
    throw new Error('Function not implemented.');
  },
  [WALLET_KEYS.COINBASE]: function (chain: ChainInfo): WalletInit {
    throw new Error('Function not implemented.');
  },
  [WALLET_KEYS.LEDGER]: function (chain: ChainInfo): WalletInit {
    throw new Error('Function not implemented.');
  },
  [WALLET_KEYS.TREZOR]: function (chain: ChainInfo): WalletInit {
    throw new Error('Function not implemented.');
  },
  [WALLET_KEYS.KEYSTONE]: function (chain: ChainInfo): WalletInit {
    throw new Error('Function not implemented.');
  },
};

export const getAllWallets = (chain: ChainInfo): WalletInits => {
  return Object.values(WALLET_MODULES).map((module) => module(chain));
};

export const isWalletSupported = (
  disabledWallets: string[],
  walletLabel: string
): boolean => {
  const legacyWalletName =
    CGW_NAMES?.[walletLabel.toUpperCase() as WALLET_KEYS];
  return !disabledWallets.includes(legacyWalletName || walletLabel);
};

export const getSupportedWallets = (chain: ChainInfo): WalletInits => {
  const enabledWallets = Object.entries(WALLET_MODULES).filter(([key]) =>
    isWalletSupported(chain.disabledWallets, key)
  );

  if (enabledWallets.length === 0) {
    return [WALLET_MODULES.INJECTED(chain)];
  }

  return enabledWallets.map(([, module]) => module(chain));
};

export const isSocialWalletEnabled = (
  chain: ChainInfo | undefined
): boolean => {
  return false;
};

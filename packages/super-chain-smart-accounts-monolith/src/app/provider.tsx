'use client';
import { ReactNode } from 'react';
import SafeThemeProvider from '../components/theme/SafeThemeProvider';
import { Theme, ThemeProvider } from '@mui/material';
import { useDarkMode } from '@/hooks/useDarkMode';
import { privyAppId } from '@/config';
import { PrivyProvider } from '@privy-io/react-auth';
import { Provider } from 'react-redux';
import { makeStore, useHydrateStore } from '@/store';
import { useInitSafeCoreSDK } from '@/hooks/coreSDK/useInitSafeCoreSDK';
import useLoadableStores from '@/hooks/useLoadableStores';
import { useInitWeb3 } from '@/hooks/wallets/useInitWeb3';
import { useTxTracking } from '@/hooks/useTxTracking';

export const AppProviders = ({
  children,
}: {
  children: ReactNode | ReactNode[];
}) => {
  const isDarkMode = useDarkMode();
  const themeMode = isDarkMode ? 'dark' : 'light';
  const reduxStore = makeStore();

  const InitApp = (): null => {
    useHydrateStore(reduxStore);
    useInitSafeCoreSDK();
    useLoadableStores();
    useInitWeb3();
    useTxTracking();

    return null;
  };

  return (
    <PrivyProvider
      appId={privyAppId}
      config={{
        appearance: {
          theme: 'light',
          accentColor: '#FF0420',
          logo: 'https://pbs.twimg.com/profile_images/1696769956245807105/xGnB-Cdl_400x400.png',
        },
        embeddedWallets: {
          createOnLogin: 'users-without-wallets',
        },
      }}
    >
      <Provider store={reduxStore}>
        <InitApp />

        <SafeThemeProvider mode={themeMode}>
          {(safeTheme: Theme) => (
            <ThemeProvider theme={safeTheme}>{children}</ThemeProvider>
          )}
        </SafeThemeProvider>
      </Provider>
    </PrivyProvider>
  );
};

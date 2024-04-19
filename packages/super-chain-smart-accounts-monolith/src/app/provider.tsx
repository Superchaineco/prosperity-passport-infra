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
    return null;
  };

  return (
    <Provider store={reduxStore}>
      <InitApp />
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
        <SafeThemeProvider mode={themeMode}>
          {(safeTheme: Theme) => (
            <ThemeProvider theme={safeTheme}>{children}</ThemeProvider>
          )}
        </SafeThemeProvider>
      </PrivyProvider>
    </Provider>
  );
};

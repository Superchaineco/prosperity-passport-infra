'use client';
import { ReactNode } from 'react';
import SafeThemeProvider from '../theme/SafeThemeProvider';
import { Theme, ThemeProvider } from '@mui/material';
import { useDarkMode } from '@/hooks/useDarkMode';
import { privyAppId } from '@/config';
import { PrivyProvider } from '@privy-io/react-auth';

export const AppProviders = ({
  children,
}: {
  children: ReactNode | ReactNode[];
}) => {
  const isDarkMode = useDarkMode();
  const themeMode = isDarkMode ? 'dark' : 'light';

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
      <SafeThemeProvider mode={themeMode}>
        {(safeTheme: Theme) => (
          <ThemeProvider theme={safeTheme}>{children}</ThemeProvider>
        )}
      </SafeThemeProvider>
    </PrivyProvider>
  );
};

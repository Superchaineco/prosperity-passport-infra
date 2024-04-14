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
          accentColor: '#676FFF',
          logo: 'https://your-logo-url',
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

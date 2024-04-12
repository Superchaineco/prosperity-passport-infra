'use client';
import { ReactNode } from 'react';
import SafeThemeProvider from '../../theme/SafeThemeProvider';
import { Theme, ThemeProvider } from '@mui/material';
import { useDarkMode } from '@/hooks/useDarkMode';

export const AppProviders = ({
  children,
}: {
  children: ReactNode | ReactNode[];
}) => {
  const isDarkMode = useDarkMode();
  const themeMode = isDarkMode ? 'dark' : 'light';

  return (
    <SafeThemeProvider mode={themeMode}>
      {(safeTheme: Theme) => (
        <ThemeProvider theme={safeTheme}>{children}</ThemeProvider>
      )}
    </SafeThemeProvider>
  );
};

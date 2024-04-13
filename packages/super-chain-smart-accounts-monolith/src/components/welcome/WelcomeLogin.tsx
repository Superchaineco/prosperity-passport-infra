import {
  Box,
  Button,
  Paper,
  SvgIcon,
  Typography,
  Divider,
} from '@mui/material';
import React from 'react';
import css from './styles.module.css';
import Link from 'next/link';

function WelcomeLogIn() {
  return (
    <Paper className={css.loginCard} data-testid='welcome-login'>
      <Box className={css.loginContent}>
        <Typography variant='h6' mt={6} fontWeight={700}>
          Get started
        </Typography>

        <Typography mb={2} textAlign='center'>
          Open your existing Safe Accounts or create a new one
        </Typography>

        {/* <WalletLogin onLogin={onLogin} /> */}

        <Divider sx={{ mt: 2, mb: 2, width: '100%' }}>
          <Typography
            color='text.secondary'
            fontWeight={700}
            variant='overline'
          >
            or
          </Typography>
        </Divider>
        <Button disableElevation size='small'>
          Watch any account
        </Button>
      </Box>
    </Paper>
  );
}

export { WelcomeLogIn };

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
import { usePrivy } from '@privy-io/react-auth';

function WelcomeLogIn() {
  const { login } = usePrivy();
  return (
    <Paper className={css.loginCard} data-testid='welcome-login'>
      <Box className={css.loginContent}>
        <Typography variant='h6' mt={6} fontWeight={700}>
          Welcome
        </Typography>

        <Typography mb={2} textAlign='center'>
          Log In or Sign Up to create a new Superchain Account or open an
          existing one
        </Typography>
        <Button
          onClick={login}
          variant='contained'
          disableElevation
          size='medium'
        >
          Get started
        </Button>

        <Divider sx={{ mt: 2, mb: 2, width: '100%' }}>
          <Typography
            color='text.secondary'
            fontWeight={700}
            variant='overline'
          >
            or
          </Typography>
        </Divider>
        <Button variant='outlined' disableElevation size='medium'>
          Accept invite
        </Button>
      </Box>
    </Paper>
  );
}

export { WelcomeLogIn };

import { Button } from '@mui/material';
import css from './styles.module.css';
import { ReactElement } from 'react';
import { usePrivy } from '@privy-io/react-auth';

export const ConnectionCenter = (): ReactElement => {
  const { login } = usePrivy();
  return (
    <Button
      onClick={login}
      className={css.login}
      variant='contained'
      size='small'
    >
      <span>Log In</span>
      or
      <span> Sign Up</span>
    </Button>
  );
};

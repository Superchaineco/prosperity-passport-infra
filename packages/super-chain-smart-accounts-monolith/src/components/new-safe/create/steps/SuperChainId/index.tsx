'use client';
import React, { useEffect, useMemo, useState } from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import { NewSafeFormData } from '../..';
import {
  Box,
  Button,
  Divider,
  Grid,
  InputAdornment,
  SvgIcon,
  Tooltip,
  Typography,
} from '@mui/material';
import InfoIcon from '@/public/images/notifications/info.svg';
import MUILink from '@mui/material/Link';
import NameInput from '@/components/common/NameInput';
import Link from 'next/link';
import { IMaskInput } from 'react-imask';
import layoutCss from '@/components/new-safe/create/styles.module.css';
import NetworkWarning from '../../NetworkWarning';
import { useWallet } from '@/hooks/useWallet';

type SetNameStepForm = {
  id: string;
  name: string;
};

enum SetNameStepFields {
  id = 'id',
  name = 'name',
}
const SET_NAME_STEP_FORM_ID = 'create-safe-set-name-step-form';

function SuperChainID({
  setSuperChainId,
  setWalletName,
}: {
  setSuperChainId: (id: string) => void;
  setWalletName: (name: string) => void;
}) {
  const { wallet } = useWallet();
  const isWrongChain = useMemo(() => {
    return wallet?.chainId !== 'eip155:10';
  }, [wallet]);

  const formMethods = useForm<SetNameStepForm>({
    mode: 'all',
  });
  const suffix = '.superchain';

  const {
    handleSubmit,
    formState: { errors, isValid },
  } = formMethods;

  const onFormSubmit = (
    data: Pick<NewSafeFormData, 'name'> & { id: string }
  ) => {
    const name = data.name;
    const id = data.id;
    setWalletName(name);
    setSuperChainId(id);
  };

  return (
    <FormProvider {...formMethods}>
      <form onSubmit={handleSubmit(onFormSubmit)} id={SET_NAME_STEP_FORM_ID}>
        <Box className={layoutCss.row}>
          <Grid container direction='column' spacing={1}>
            <Grid item xs>
              <NameInput
                name={SetNameStepFields.id}
                label={
                  errors?.[SetNameStepFields.name]?.message || 'SuperChain ID'
                }
                placeholder={'name'}
                required
                InputLabelProps={{ shrink: true }}
                InputProps={{
                  onChange: (e) => {
                    e.target.value = e.target.value.toLocaleLowerCase();
                    if (!e.target.value.length) {
                      setSuperChainId('');
                      return;
                    }
                    setSuperChainId(e.target.value + suffix);
                  },
                  endAdornment: (
                    <>
                      <InputAdornment position='end'>
                        <Typography variant='body2' color='secondary.main'>
                          {suffix}
                        </Typography>
                      </InputAdornment>
                      <Tooltip
                        title='This name is stored locally and will never be shared with us or any third parties.'
                        arrow
                        placement='top'
                      >
                        <InputAdornment position='end'>
                          <SvgIcon component={InfoIcon} inheritViewBox />
                        </InputAdornment>
                      </Tooltip>
                    </>
                  ),
                }}
              />
            </Grid>
            <Grid item xs>
              <NameInput
                name={SetNameStepFields.name}
                label={
                  errors?.[SetNameStepFields.name]?.message ||
                  'Wallet name (Optional)'
                }
                placeholder={'Name'}
                InputLabelProps={{ shrink: true }}
                InputProps={{
                  onChange: (e) => {
                    setWalletName(e.target.value);
                  },
                  endAdornment: (
                    <Tooltip
                      title='This name is stored locally and will never be shared with us or any third parties.'
                      arrow
                      placement='top'
                    >
                      <InputAdornment position='end'>
                        <SvgIcon component={InfoIcon} inheritViewBox />
                      </InputAdornment>
                    </Tooltip>
                  ),
                }}
              />
            </Grid>
          </Grid>
          <Typography variant='body2' mt={2}>
            By continuing, you agree to our{' '}
            <Link href={'/#'} passHref legacyBehavior>
              <MUILink>terms of use</MUILink>
            </Link>{' '}
            and{' '}
            <Link href={'/#'} passHref legacyBehavior>
              <MUILink>privacy policy</MUILink>
            </Link>
            .
          </Typography>

          {isWrongChain && <NetworkWarning />}
        </Box>
        <Divider />
        <Box className={layoutCss.row}>
          <Box
            display='flex'
            flexDirection='row'
            justifyContent='space-between'
            gap={3}
          >
            <Button data-testid='cancel-btn' variant='outlined' size='small'>
              Cancel
            </Button>
            <Button
              data-testid='next-btn'
              type='submit'
              variant='contained'
              size='stretched'
              disabled={!isValid || isWrongChain}
            >
              Next
            </Button>
          </Box>
        </Box>
      </form>
    </FormProvider>
  );
}

export default SuperChainID;

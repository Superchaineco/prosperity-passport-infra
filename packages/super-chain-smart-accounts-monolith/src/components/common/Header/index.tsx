import type { Dispatch, SetStateAction } from 'react';
import { type ReactElement } from 'react';
import { useRouter } from 'next/navigation';
import { Button, IconButton, Paper, SvgIcon } from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
import classnames from 'classnames';
import css from './styles.module.css';
import Link from 'next/link';
import WalletConnect from '@/assets/images/common/walletconnect.svg';
import BellIcon from '@/assets/images/common/notifications.svg';
import SuperChainEco from '@/assets/images/common/superchain-eco.svg';
import ButtonBase from '@mui/material/ButtonBase';

type HeaderProps = {
  onMenuToggle?: Dispatch<SetStateAction<boolean>>;
  onBatchToggle?: Dispatch<SetStateAction<boolean>>;
};

const Header = ({ onMenuToggle }: HeaderProps): ReactElement => {
  const router = useRouter();

  const logoHref = '/#';

  const handleMenuToggle = () => {
    if (onMenuToggle) {
      onMenuToggle((isOpen) => !isOpen);
    } else {
      router.push(logoHref);
    }
  };

  return (
    <Paper className={css.container}>
      <div
        className={classnames(
          css.element,
          css.menuButton,
          !onMenuToggle ? css.hideSidebarMobile : null
        )}
      >
        <IconButton
          onClick={handleMenuToggle}
          size='large'
          color='default'
          aria-label='menu'
        >
          <MenuIcon />
        </IconButton>
      </div>

      <div className={classnames(css.element, css.hideMobile, css.logo)}>
        <Link href={logoHref} passHref>
          <SvgIcon
            component={SuperChainEco}
            inheritViewBox
            style={{ width: '200px', height: '100px' }}
          />
        </Link>
      </div>

      <div className={classnames(css.element, css.button)}>
        <SvgIcon component={BellIcon} inheritViewBox className={css.icon} />
      </div>

      <div className={classnames(css.element, css.button)}>
        <SvgIcon
          component={WalletConnect}
          inheritViewBox
          className={css.icon}
        />
      </div>
      <div className={classnames(css.element, css.button)}>
        <Button variant='contained' size='small'>
          Log In or Sign Up
        </Button>
      </div>
    </Paper>
  );
};

export default Header;

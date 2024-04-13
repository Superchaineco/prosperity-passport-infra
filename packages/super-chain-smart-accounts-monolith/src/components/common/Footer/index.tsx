import type { ReactElement, ReactNode } from 'react';
import { SvgIcon, Typography } from '@mui/material';
import GitHubIcon from '@mui/icons-material/GitHub';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import css from './styles.module.css';
import packageJson from '../../../../package.json';
import ExternalLink from '../ExternalLink';
import MUILink from '@mui/material/Link';

const footerPages = ['#', '#', '#', '#'];

const FooterLink = ({
  children,
  href,
}: {
  children: React.ReactNode;
  href: string;
}): ReactElement => {
  return href ? (
    <Link href={href} passHref legacyBehavior>
      <MUILink>{children}</MUILink>
    </Link>
  ) : (
    <MUILink>{children}</MUILink>
  );
};

const Footer = (): ReactElement | null => {
  return (
    <footer className={css.container}>
      <ul>
        <>
          <li>
            <Typography variant='caption'>Kolektivo Labs © 2024</Typography>
          </li>
          <li>
            <FooterLink href='/#'>Terms</FooterLink>
          </li>
          <li>
            <FooterLink href='/#'>Terms</FooterLink>
          </li>
          <li>
            <FooterLink href='/#'>Terms</FooterLink>
          </li>
          <li>
            <FooterLink href='/#'>Terms</FooterLink>
          </li>
          <li>
            <FooterLink href='/#'>Terms</FooterLink>
          </li>
          <li>
            <FooterLink href='/#'>Terms</FooterLink>
          </li>
        </>

        <li>
          <ExternalLink href={`#/releases/tag/v${packageJson.version}`} noIcon>
            <SvgIcon
              component={GitHubIcon}
              inheritViewBox
              fontSize='inherit'
              sx={{ mr: 0.5 }}
            />{' '}
            v{packageJson.version}
          </ExternalLink>
        </li>
      </ul>
    </footer>
  );
};

export default Footer;

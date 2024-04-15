import { type ReactElement } from 'react';
import SrcEthHashInfo, { type EthHashInfoProps } from './SrcEthHashInfo';

const EthHashInfo = ({
  showName = true,
  avatarSize = 40,
  ...props
}: EthHashInfoProps & { showName?: boolean }): ReactElement => {
  return (
    <SrcEthHashInfo
      prefix='Optimism'
      copyPrefix={false}
      {...props}
      name={undefined}
      customAvatar={props.customAvatar}
      avatarSize={avatarSize}
    >
      {props.children}
    </SrcEthHashInfo>
  );
};

export default EthHashInfo;

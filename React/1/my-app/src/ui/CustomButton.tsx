import React from 'react';
import { Button, ButtonProps, CircularProgress, Tooltip } from '@mui/material';

interface ICustomButtonProps extends ButtonProps {
  loading?: boolean;
  tooltip?: string;
}

export const CustomButton: React.FC<ICustomButtonProps> = ({
  children,
  loading = false,
  tooltip,
  disabled,
  ...props
}) => {
  const button = (
    <Button disabled={disabled || loading} {...props}>
      {loading ? <CircularProgress size={24} /> : children}
    </Button>
  );

  if (tooltip) {
    return <Tooltip title={tooltip}>{button}</Tooltip>;
  }

  return button;
};
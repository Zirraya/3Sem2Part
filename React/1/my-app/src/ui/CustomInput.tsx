import React from 'react';
import { TextField, TextFieldProps } from '@mui/material';

export const CustomInput: React.FC<TextFieldProps> = (props) => {
  return (
    <TextField
      variant="outlined"
      fullWidth
      size="medium"
      {...props}
    />
  );
};